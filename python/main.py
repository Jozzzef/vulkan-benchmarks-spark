#external imports
import subprocess
from pyspark.sql import SparkSession
import os
import sys
#internal imports
sys.path.append(os.path.dirname(__file__))
from parsing_algorithms.simple_example import simple_parser 

def collect_log_data(parsers: list[function], rdd_input) -> list[str]:
    """
    Executed on a Spark executor.
    1. Run all of the binaries
    """

    print("collecting logs with the following parsers:   ", parsers)
    print("this is the current data", rdd_input)
    return [""]


if __name__ == "__main__":
    print("running all the binaries...")
    # Run all of the binaries you need to run to get the logs from
    proc = subprocess.run(
        ["./executor_run_binaries.sh"],
        capture_output=True,
        text=True,
        check=True # raises if the command exits non‑zero
    )
    print(proc)

    #create the spark session
    spark = SparkSession.builder \
        .appName("K8s-PySpark-App") \
        .master("k8s://https://<api-server>:6443") \
        .config("spark.kubernetes.namespace", "pyspark") \
        .getOrCreate()

    # Parallelize a dummy list just to launch N tasks (here 4 tasks)
    rdd = spark.sparkContext.parallelize(range(4), numSlices=4)

    # Each task runs `create_and_process` and returns its three lines
    result = rdd.map(lambda x: collect_log_data([simple_parser], x)).collect()

    for idx, lines in enumerate(result):
        print(f"Task {idx} output:")
        for line in lines:
            print(f"  {line}")

    spark.stop()

