#!/usr/bin/env nextflow

process SPLITLETTERS {
    
    input:
    tuple val(prefix), val(input_str), val(meta)

    output:
    path "chunk_${prefix}_*.txt", emit: chunk_files

    script:
    """
    in_str="${input_str}"
    size=${meta}

    for (( i=0; i<\${#in_str}; i+=size)); do
        chunk=\${in_str:i:size}
        echo "\$chunk" > chunk_${prefix}_\$i.txt
    done
    """

} 

process CONVERTTOUPPER {

    input:
    path chunk_file

    output:
    stdout

    script:
    """
    cat ${chunk_file} | tr '[:lower:]' '[:upper:]'
    """

} 

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout

    // read in samplesheet
    samplesheet_2 = channel.fromPath('samplesheet_2.csv').splitCsv(header:true)
    in_ch = samplesheet_2.map { row ->
        def prefix = row.prefix
        def in_str = row.input_str
        def metadata = row.block_size
        return [prefix, in_str, metadata]
    }

    // split the input string into chunks
    chunks_ch = SPLITLETTERS(in_ch)

    // lets remove the metamap to make it easier for us, as we won't need it anymore

    // convert the chunks to uppercase and save the files to the results directory
    upper_ch = CONVERTTOUPPER(chunks_ch.flatten())
    upper_ch.view()

}