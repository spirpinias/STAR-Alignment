This [Code Ocean](https://codeocean.com) Compute Capsule will allow you to run and reproduce the results of [STAR-Solo Alignment](https://apps.codeocean.com/capsule/7794569/tree) on your local machine<sup>1</sup>. Follow the instructions below, or consult [our knowledge base](https://docs.codeocean.com/user-guide/compute-capsule-basics/managing-capsules/exporting-capsules-to-your-local-machine) for more information. Don't hesitate to reach out to [Support](mailto:support@codeocean.com) if you have any questions.

<sup>1</sup> You may need access to additional hardware and/or software licenses.

# Prerequisites

- [Docker Community Edition (CE)](https://www.docker.com/community-edition)

# Instructions

## Log in to the Docker registry

In your terminal, execute the following command, providing your password or API key when prompted for it:
```shell
docker login -u stephen@codeocean.com registry.apps.codeocean.com
```

## Run the Capsule to reproduce the results

In your terminal, navigate to the folder where you've extracted the Capsule and execute the following command, adjusting parameters as needed:
```shell
docker run --platform linux/amd64 --rm \
  --workdir /code \
  --volume "$PWD/code":/code \
  --volume "$PWD/data":/data \
  --volume "$PWD/results":/results \
  registry.apps.codeocean.com/capsule/8e0528c5-da93-46f8-acf0-eeaa92a097b8 \
  bash run '' '' _S1_L001_R1_001.fastq.gz _S1_L001_R2_001.fastq.gz _S1_L001_R3_001.fastq.gz False zcat SortedByCoordinate - None 'WithinBAM HardClip' None False 10 CellRanger2.2 Gene Unique 1MM_All - '' 1 16 17 10 1 1 1,10 1,10
```
