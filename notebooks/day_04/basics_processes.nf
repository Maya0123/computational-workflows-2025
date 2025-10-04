params.step = 0
params.zip = 'zip'

// For me: use python -c

process SAYHELLO {

    debug true

    script:
    """
    echo 'Hello World!'
    """
}

process SAYHELLO_PYTHON{

    debug true

    script:
    """
    python -c "print('Hello World!')"
    """
}
process SAYHELLO_PARAM{

    debug true 

    input:
    val greeting

    exec:
    message = "${greeting}"

    output:
    val message

}

process SAYHELLO_FILE{

    input:
    val greeting

    output:
    path "HelloWorld.txt"

    script:
    """
    echo "${greeting}" > HelloWorld.txt
    """

}

process UPPERCASE{

    input:
    val greeting

    output:
    path "Uppercase.txt"

    script:
    """
    echo "${greeting}" | tr '[:lower:]' '[:upper:]' > Uppercase.txt
    """
}

process PRINTUPPER{

    debug true

    input:
    path file_uppercase

    script:
    """
    cat $file_uppercase
    """
}

process ZIP_FILE{

    input:
    path file_uppercase
    val zip_format

    output:
    path "*", emit: zipped_file

    script:
    if (zip_format == "zip"){

    """
    zip ${file_uppercase}.zip $file_uppercase
    """

    } else if (zip_format == "gzip"){
    
    """
    gzip -c $file_uppercase > ${file_uppercase}.gz
    """

    } else if (zip_format ==  "bzip2"){

    """
    bzip2 -c $file_uppercase > ${file_uppercase}.bz2 
    """

    }
}

process ZIP_ALL_FILES{

    input:
    path file_uppercase

    output:
    path "*", emit: zipped_files

    script:
    """
    zip ${file_uppercase}.zip $file_uppercase
    gzip -c $file_uppercase > ${file_uppercase}.gz
    bzip2 -c $file_uppercase > ${file_uppercase}.bz2
    """

}

process WRITETOFILE{

publishDir "results/"

input:
val list

output:
path "names.tsv"

script:
"""
echo -e "name\ttitle" > names.tsv
${list.collect { person -> "echo -e \"${person.name}\t${person.title}\" >> names.tsv "}.join('\n')}
"""

}


workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == 1) {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == 2) {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == 3) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // The file can be found under work/aa/bc4f75a562904dec9535be2a7f9f23/HelloWorld.txt
    // (Work directory of nextflow. There all intermediate results are stored)

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == 5) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }
    // path to the file: work/35/3b61968228019fbb5cffc3438ffbf3/Uppercase.txt


    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == 7) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)

        zip_format = Channel.of(params.zip)
        zipped_file_ch = ZIP_FILE(out_ch, zip_format)
        zipped_file_ch.view()
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)

        zipped_files_ch = ZIP_ALL_FILES(out_ch)
        zipped_files_ch.view()
    }

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == 9) {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )
        // continue here
        list_ch = in_ch.collect()
        out_ch = WRITETOFILE(list_ch)
        out_ch.view()
            
    }

}