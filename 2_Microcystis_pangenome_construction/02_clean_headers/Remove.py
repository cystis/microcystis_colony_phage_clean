infile = open("/lustre/isaac/proj/UTK0002/TAIHU/TAIHU_2024/newfrank2/total15protein.faa", 'r')
outfile = open("headers_Removed_15protein.faa", 'w')
read = infile.readlines()
assembly_dict = {}
for line in read:
    line = line.strip()
    if line.startswith('>'):
        head = line.split(' ')[0]
        assembly_dict[head] = ''
    else:
        query = line
        assembly_dict[head] += query
for x in assembly_dict:
    head = x
    seq = assembly_dict[x]
    outfile.write('%s\n%s\n' % (head, seq))

infile.close()
outfile.close()

