# 简化版：不包含功能注释
fasta_in = 'Frankenstein_microcystis_0.95_2024.fna'  # 输入FASTA文件名
gff_out = 'Frank_microcystis_0.95_2024.gff3'  # 输出GFF3文件名

# 打开输入和输出文件
fasta = open(fasta_in, 'r')
gff = open(gff_out, 'w')

gene_dict = {}  # 用于存储基因ID和序列

fasta_read = fasta.readlines()  # 读取FASTA文件
fasta.close()

# 解析FASTA文件
for line in fasta_read:
    line = line.strip()
    if line.startswith('>'):  # 如果是FASTA的header
        header = line.split(' ')[0].replace('>', '')  # 提取基因ID
        gene_dict[header] = ''  # 初始化序列为空
    else:
        gene_dict[header] += line  # 将序列加到对应的基因ID

# 生成GFF3文件
for gene_id, seq in gene_dict.items():
    length = len(seq)  # 计算序列长度
    # 写入GFF3文件，不包含功能注释
    gff.write(f'{gene_id}\tFrankenstein\tgene\t1\t{length}\t.\t+\t.\tID={gene_id}.1\n')

gff.close()  # 关闭输出文件

