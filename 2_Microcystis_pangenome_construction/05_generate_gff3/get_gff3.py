fasta_in = 'Frankenstein_microcystis_0.95_2024.fna'  # Input FASTA file name
gff_out = 'Frank_microcystis_0.95_2024.gff3'         # Output GFF3 file name

# Open input and output files
fasta = open(fasta_in, 'r')
gff = open(gff_out, 'w')

gene_dict = {}  # Store gene IDs and sequences

fasta_read = fasta.readlines()  # Read FASTA file
fasta.close()

# Parse FASTA content
for line in fasta_read:
    line = line.strip()
    if line.startswith('>'):  # FASTA header
        header = line.split(' ')[0].replace('>', '')  # Extract gene ID
        gene_dict[header] = ''  # Initialize empty sequence
    else:
        gene_dict[header] += line  # Append sequence to corresponding gene ID

# Generate GFF3 output
for gene_id, seq in gene_dict.items():
    length = len(seq)  # Calculate sequence length
    # Write to GFF3 file without functional annotations
    gff.write(f'{gene_id}\tFrankenstein\tgene\t1\t{length}\t.\t+\t.\tID={gene_id}.1\n')

gff.close()  # Close output file