
# === Set working directory to project root (if running from R_scripts/) ===
if (requireNamespace("rstudioapi", quietly = TRUE)) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(file.path(script_path, ".."))
}

# 定义搜索的关键词
save_path <- "results/"
study_object <- "2023_PEP-CTERM"
search_keywords <- c("PEP-CTERM")

# 读取CSV文件
merged_df2 <- read.csv("rawdata/annotation/2023_base10_annotation.csv")
# 初始化存储搜索结果的空数据框
all_matches <- data.frame()

# 初始化一个列表来存储每个关键词的匹配数量
keyword_count <- data.frame(Keyword = character(), Count = integer(), stringsAsFactors = FALSE)

# 遍历每个关键词进行搜索
for (keyword in search_keywords) {
  # 搜索关键词匹配的条目
  new_df <- merged_df2[
    grepl(keyword, merged_df2$protein, ignore.case = TRUE) |
      grepl(keyword, merged_df2$Description, ignore.case = TRUE) |
      grepl(keyword, merged_df2$manual, ignore.case = TRUE) |
      grepl(keyword, merged_df2$KEGG_Pathway, ignore.case = TRUE),
  ]
  
  # 记录当前关键词的匹配数量
  keyword_count <- rbind(keyword_count, data.frame(Keyword = keyword, Count = nrow(new_df), stringsAsFactors = FALSE))
  
  # 将结果添加到总的数据框中
  all_matches <- rbind(all_matches, new_df)
}

# 去除重复条目
unique_matches <- unique(all_matches)

# 输出每个关键词的匹配数量
print(keyword_count)

# 查看去重后的总数
cat("Total unique matches after removing duplicates:", nrow(unique_matches), "\n")

library(ggplot2)
# 读取数据
df <- unique_matches

# 过滤缺失值
df <- df[!is.na(df$padj) & !is.na(df$log2FoldChange), ]

# 添加一个新列来标记基因的状态
df$threshold <- as.factor(ifelse(df$padj < 0.05 & df$log2FoldChange > 1, "Up-regulated",
                                 ifelse(df$padj < 0.05 & df$log2FoldChange < -1, "Down-regulated", "Not significant")))

# 筛选出上调和下调的基因
selected_genes <- df[df$threshold %in% c("Up-regulated", "Down-regulated"), ]

# 从合并的上调和下调基因中选择 log2FoldChange 绝对值最大的前 10 个基因
top_genes <- selected_genes[order(-abs(selected_genes$log2FoldChange)), ][1:10, ]

# 检查结果
#head(top_genes)

library(ggrepel)
# 绘制火山图
volcano_plot <- ggplot(df, aes(x = log2FoldChange, y = -log10(padj), color = threshold)) +
  geom_point(alpha = 0.8, size = 1) +  # 调整透明度和点的大小
  scale_color_manual(values = c("Up-regulated" = "#E5A092", "Down-regulated" = "#87A7E0", "Not significant" = "#A6A6A6"), 
                     name = NULL) +  # 去掉图例标题
  geom_text_repel(data = top_genes, aes(label = gene_name), size = 2.7, color = "black", segment.color = "black", max.overlaps = Inf, force = 1, box.padding = 0.5, point.padding = 0.5) +  # 仅为前10个 log2FoldChange 最大的基因添加标签
  # 显著性阈值线（横向和纵向）
  geom_vline(xintercept = c(-1, 1), linetype = "dotted", color = "#A6A6A6", size = 0.5) +  # 用小点线表示Fold change阈值线
  geom_hline(yintercept = -log10(0.05), linetype = "dotted", color = "#A6A6A6", size = 0.5) +  # 用小点线表示显著性阈值线
  
  # 自定义纵坐标刻度，标出 -log10(0.05)
  scale_y_continuous(breaks = c(0, 5, 10, 15), labels = c("0", "5", "10", "15")) +  # 在坐标轴上标出 0.05
  
  scale_x_continuous(limits = c(-6, 6), breaks = seq(-6, 6, by = 2)) +  # 设置对称的X轴刻度
  
  labs(x = "Fold change (log2)", y = "Adjusted P-value (-log10)") +
  
  theme_minimal() +  # 去掉背景线
  
  theme(
    
    
    # 设置图例文本和标题大小
    legend.position = "bottom",  # 将图例放置在底部中间
    legend.text = element_text(size = 7),  # 调整图例标签字体大小
    legend.spacing.x = unit(0, "mm"),  # 图例项之间的水平空隙
    legend.spacing.y = unit(0, "mm"),  # 图例项之间的垂直空隙
    legend.margin = margin(t = 0, b = 0, l = 0, r = 0),  # 整个图例与图形边缘的空隙
    
    # 设置横纵坐标标题字体大小
    axis.title.x = element_text(margin = margin(t = 5), size = 10),  # X轴标题字体大小为10，距图形顶部10
    axis.title.y = element_text(margin = margin(r = 5), size = 10),  # Y轴标题字体大小为10，距图形右边10
    
    # 设置刻度线长度
    axis.ticks.length = unit(0.15, "cm"),  # 刻度线长度，影响刻度与刻度标签之间的距离
    
    # 设置整个图形的边界
    plot.margin = margin(2, 2, 2, 2, "mm"),  # 图形上下左右的边距
    panel.border = element_rect(color = "black", fill = NA, size = 0.5),  # 添加黑色边框
    panel.grid = element_blank(),  # 去掉背景网格线
    panel.background = element_rect(fill = "white", color = NA),  # 背景白色
    plot.background = element_rect(fill = "white", color = NA),  # 整个图形背景白色
    aspect.ratio = 1,  # 设置正方形比例
    
    axis.line = element_line(color = "black"),  # 添加X轴和Y轴的竖线
    axis.ticks = element_line(color = "black")  # 设置坐标轴刻度线的颜色
  ) +
  
  coord_cartesian(clip = "off")  # 确保所有点都显示在图框内

print(volcano_plot)

# 计算不同类别的数量
table(df$threshold)

# 保存图片为png格式
ggsave(paste0(save_path, "volcano_", study_object, ".pdf"), volcano_plot, width = 4, height = 4, units = "in")
