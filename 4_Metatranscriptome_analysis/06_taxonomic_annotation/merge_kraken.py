# -*- coding: utf-8 -*-

infile = open('Kraken2_LT_2024_full_classification_new.txt', 'r')
read = infile.readlines()
infile.close()

taxa = {}
levels = ['d__', 'k__', 'p__', 'c__', 'o__', 'f__', 'g__', 's__']

for line in read:
    line = line.strip()
    if line.startswith('d'):
        taxon_parts = line.split('\t')[0].split('|')
        taxon_dict = {level[:2]: 'NA' for level in levels}
        for part in taxon_parts:
            prefix = part[:2]
            if prefix in taxon_dict:
                taxon_dict[prefix] = part
        combined = '\t'.join([taxon_dict[level[:2]] for level in levels])
        final = taxon_parts[-1].split('__')[-1]
        taxa[final] = combined

infile = open('Kraken2_LT_2024_taxonomic_results_new.txt')
read = infile.readlines()
outfile = open('merged_taxonomy_new1.txt', 'w')

# 写入列名
column_names = ['Annotation_Status', 'Gene', 'Domain', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species', 'Strain']
outfile.write('\t'.join(column_names) + '\n')

for line in read:
    line = line.strip()
    total = ''

    if line.startswith('U'):
        taxonomy = '\t'.join(['NA'] * len(levels))
        kraken = line.split('\t')
        kraken1 = '\t'.join(kraken[0:2])
        kraken2 = '\t'.join(kraken[2:5])
        total = "{}\t{}\t{}".format(kraken1, taxonomy, kraken2)
    else:
        kraken = line.split('\t')
        taxon = kraken[2].split(' (')[0]
        if 'unclassified' in taxon:
            taxon = taxon.replace('unclassified ', '')
        if ' sp.' not in taxon and 'Candidatus' not in taxon and 'phage' not in taxon and 'virus' not in taxon and 'endosymbiont' not in taxon:
            taxonsplit = taxon.split(' ')
            if len(taxonsplit) > 1:
                taxon = ' '.join(taxonsplit[0:2])
                if 'group' in taxon:
                    taxon = taxon.split(' group')[0]
            else:
                taxon = taxonsplit[0]

        kraken1 = '\t'.join(kraken[0:2])
        kraken2 = '\t'.join(kraken[2:5])
        if taxon == 'root' or taxon == 'cellular organisms' or taxon == 'other sequences':
            taxonomy = '\t'.join(['NA'] * len(levels))
        elif taxon == 'Terrabacteria':
            taxonomy = 'd__Bacteria\tp__Unclassified Terrabacteria\t' + '\t'.join(['NA'] * (len(levels) - 2))
        elif taxon in taxa:
            taxonomy = taxa[taxon]
        elif 'phage' in taxon:
            taxonomy = 'd__Viruses\tk__Heunggongvirae\tp__Uroviricota\tc__Caudoviricetes' + '\tNA' * (len(levels) - 4)
        else:
            taxonomy = '\t'.join(['BAD_TAXON'] * len(levels))

        # 将 Species 列的内容只保留空格前的部分
        taxonomy_columns = taxonomy.split('\t')
        if taxonomy_columns[7] != 'NA':  # 如果 Species 列不为空白
            taxonomy_columns[7] = taxonomy_columns[7].split(' ')[0]
        taxonomy = '\t'.join(taxonomy_columns)

        total = "{}\t{}\t{}".format(kraken1, taxonomy, kraken2)

    outfile.write(total + '\n')

outfile.close()

