rule index_original_prg:
    input:
        prg = original_prg
    output:
        linked_prg = output_folder+"/prgs/prg.fa",
        index = output_folder + "/prgs/prg.fa.k15.w14.idx",
        kmer_prgs = directory(output_folder + "/prgs/kmer_prgs")
    threads: 16
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 16000
    params:
        pandora_exec = pandora_exec
    log:
        "logs/index_original_prg.log"
    shell:
        """
        cp {input.prg} {output.linked_prg}
        {params.pandora_exec} index -t {threads} {output.linked_prg} >{log} 2>&1
        """


rule map_with_discovery:
    input:
        prg = rules.index_original_prg.output.linked_prg,
        index = rules.index_original_prg.output.index,
        reads = lambda wildcards: get_reads(subsampled_reads, wildcards.technology, wildcards.sample, wildcards.coverage, wildcards.sub_strategy),
        ref = lambda wildcards: get_assembly(samples_df, wildcards.sample)
    output:
        outdir=directory(output_folder + "/{technology}/{coverage}x/{sub_strategy}/{sample}/map_with_discovery")
    threads: 16
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 30000,
    params:
        log_level="debug",
        use_discover=True,
        pandora_exec = pandora_exec,
    log:
        "logs/map_with_discovery/{technology}/{coverage}x/{sub_strategy}/{sample}.log"
    shell:
        """
        bash scripts/pandora_map.sh {params.pandora_exec} {input.prg} \
            {input.reads} \
            {output.outdir} \
            {threads} \
            {wildcards.technology} \
            {params.log_level} \
            {log} \
            {params.use_discover} \
            {input.ref}
        """
