rm(list=ls())
# 1. 加载必要的 R 包
library(Seurat)
library(ggplot2)
library(dplyr)
library(readr)

# 2. 设置路径并加载数据 (以海马体为例，你也可以换成 Prefrontal_cortex)
data_dir <- "/storage/zhenghoufengLab/share/AD/ROSMAP/single_cell_RNA_seq/"
meta_dir <- "/storage/zhenghoufengLab/share/AD/ROSMAP/"

# 加载单细胞 RDS 数据
print("Loading Seurat Object...")
seurat_obj <- readRDS(paste0(data_dir, "Hippocampus.rds"))

# 3. 检查并导入细胞注释 (如果 RDS 中没有自带 Cell Type)
# ROSMAP 的细胞注释文件在同目录下
cell_labels <- read_tsv(paste0(data_dir, "all_brain_regions_filt_preprocessed_scanpy_norm.final_noMB.cell_labels.tsv"))

# 假设你的 seurat_obj 的 cell names (rownames of metadata) 可以和 cell_labels 匹配
# （注意：具体匹配的主键可能需要根据你的 rownames 调整）
seurat_meta <- seurat_obj@meta.data
seurat_meta$barcode <- rownames(seurat_meta)
# 将注释 merge 进 meta.data
# 使用 "barcode" 作为共同的键值进行合并
seurat_obj@meta.data <- left_join(seurat_meta, cell_labels, by = "barcode") 

# 重新赋予行名（非常重要，因为 left_join 默认会抹掉原始数据框的行名）
rownames(seurat_obj@meta.data) <- seurat_obj@meta.data$barcode

# 将细胞类型设为当前 identity (假设注释列名为 'cell_type')
Idents(seurat_obj) <- "cell_type" 

# 4. 定义你需要展示的关键基因
# 注意: MAPT-AS1 是 lncRNA，在 snRNA-seq 中检出率可能较低，请先验证其是否在矩阵中
features_to_plot <- c("MAPT", "MAPT-AS1", "PIK3CA", "AKT1", "AKT2", "AKT3")

# 检查基因是否存在于表达矩阵中，过滤掉不存在的
available_features <- intersect(features_to_plot, rownames(seurat_obj))
print(paste("Available genes:", paste(available_features, collapse = ", ")))

# --- 绘图 1: 高质量的 DotPlot (气泡图) ---
# 这张图可以放在正文，展示你关注的基因确实在你 MR 发现的细胞中高表达
dot_plot <- DotPlot(seurat_obj, features = available_features, 
                    cols = c("lightgrey", "#b2182b"), # 使用高端的红灰配色
                    dot.scale = 8) + 
  RotatedAxis() +
  labs(title = "Expression of Key Shared Genes Across Brain Cell Types",
       x = "Key Genes", y = "Cell Type") +
  theme(axis.text.x = element_text(face = "italic"), # 基因名斜体
        plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave("Figure_DotPlot_KeyGenes.pdf", plot = dot_plot, width = 8, height = 6)


# --- 绘图 2: 关注特定细胞亚型的 VlnPlot (小提琴图) ---
# 仅提取你 MR 结果显著的细胞类型进行绘图
target_cells <- subset(seurat_obj, idents = c("Pericytes", "Astrocytes", "OPCs")) # 请替换为实际的细胞名称，例如 "Astro", "Oligo"

vln_plot <- VlnPlot(target_cells, features = available_features, 
                    pt.size = 0, # 去掉散点以保持小提琴图整洁
                    ncol = 2) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("Figure_VlnPlot_TargetCells.pdf", plot = vln_plot, width = 10, height = 8)


# --- 绘图 3: 热图 (如果审稿人特别想要) ---
# 注意：做热图时细胞太多会糊掉，建议每种细胞随机抽样 100-200 个细胞
sampled_cells <- subset(target_cells, downsample = 100)
heatmap_plot <- DoHeatmap(sampled_cells, features = available_features, size = 4, angle = 90) +
  theme(axis.text.y = element_text(face = "italic")) +
  scale_fill_gradientn(colors = c("#2166ac", "white", "#b2182b")) # 蓝白红配色

ggsave("Figure_Heatmap_TargetCells.pdf", plot = heatmap_plot, width = 8, height = 6)




# 1. 把 major_cell_type 设置为当前 Seurat 对象的默认分类标签
Idents(seurat_obj) <- "major_cell_type"

# 2. 精准提取你 MR 结果中显著的这三种目标细胞
target_cells <- subset(seurat_obj, idents = c("Ast", "Per", "OPC"))

# 3. 定义你想要展示的关键基因
# (注意：MAPT-AS1 作为 lncRNA 可能由于单核测序深度问题检测不到。如果画图报错，可以将它从这里移除，仅展示 MAPT 和 PI3K/AKT 通路基因)
features_to_plot <- c("MAPT", "MAPT-AS1", "PIK3CA", "AKT1", "AKT2", "AKT3")

# 过滤出真正在表达矩阵中存在的基因，防止报错
available_features <- intersect(features_to_plot, rownames(target_cells))
print(paste("可用于绘图的基因:", paste(available_features, collapse = ", ")))

# 4. 绘制高质量气泡图 (DotPlot) - 展示这些基因在三种细胞里的基础表达分布
dot_plot <- DotPlot(target_cells, features = available_features, 
                    cols = c("lightgrey", "#b2182b"), # 灰红配色，高亮高表达基因
                    dot.scale = 8) + 
  RotatedAxis() +
  labs(title = "Expression of Key Genes in Mediating Cell Types",
       x = "Key Genes", y = "Cell Type") +
  theme(axis.text.x = element_text(face = "italic", angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5, face = "bold"))

# 保存气泡图到当前工作目录
ggsave("Figure1_DotPlot_KeyGenes.pdf", plot = dot_plot, width = 7, height = 5)

# 5. 绘制基础小提琴图 (VlnPlot) - 展示表达量分布
vln_plot <- VlnPlot(target_cells, features = available_features, 
                    pt.size = 0, # 设置为0可以隐藏单细胞的散点，让小提琴图更干净
                    ncol = 2) +  # 每行放2个基因的图
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 保存小提琴图
ggsave("Figure2_VlnPlot_KeyGenes.pdf", plot = vln_plot, width = 10, height = 8)

print("绘图完成！请在当前目录下查看 Figure1 和 Figure2 的 PDF 文件。")
