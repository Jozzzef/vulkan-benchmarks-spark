#external imports
from pyspark.sql import SparkSession
import os
import sys
from typing import Callable
import subprocess

#internal imports
sys.path.append(os.path.dirname(__file__))
from parsing_algorithms.simple_example import simple_parser 

#still needs to be written
def collect_log_data(parsers: list[Callable[[str], str]], rdd_input: str) -> list[str]:
    """
    Executed on a Spark executor.
    1. Run all of the binaries
    """

    print("collecting logs with the following parsers:   ", parsers)
    print("this is the current data", rdd_input)
    return [""]


if __name__ == "__main__":
    #get the endpoint for kubernetes
    print("")
    print("PYTHON SCRIPT RUNNING =================")
    param1 = sys.argv[1] if len(sys.argv) > 1 else None
    print(param1)
    #create the spark session
    spark = (SparkSession.builder
        .appName("pyspark-app")
        .master(f"k8s://https://{param1}")
        .config("spark.kubernetes.namespace", "pyspark")
        .config("spark.executor.instances", "2")
        .config("spark.executor.memory", "1g")
        .config("spark.driver.bindAddress", "0.0.0.0")
        .getOrCreate())
    print("spark -> ", spark)

    # Master computer compute it's logs in a distributed fashion, first as a proof of concept
    # then display to show that went correctly on master computer

    # LOCAL FILES COMPUTE -> Use Pandas -> spark collect
    # Read all text files from local executor into a single column 'value'
    #df = spark.read.format("text") \ #    .option("pathGlobFilter", "*.txt") \
    #    .option("localFiles", "true") \
    #    .load("./logs")

    ## Each task runs `create_and_process` and returns its three lines
    #result_rdd = df.rdd.map(lambda x: collect_log_data([simple_parser], str(x))).collect()
    #
    #for idx, lines in enumerate(result_rdd):
    #    print(f"Task {idx} output:")
    #    for line in lines:
    #        print(f"  {line}")

    spark.stop()

