from time import sleep


struct MyDefaultTask[name: StringLiteral]:
    fn __init__(out self):
        pass

    fn __call__(self):
        print("Task [", name, "] Running...")
        sleep(0.5)


struct MyTask[job: StringLiteral]:
    var some_data: String

    fn __init__(out self, owned some_data: StringLiteral):
        self.some_data = some_data

    fn __call__(self):
        print("Running [", job, "]:", self.some_data)
        sleep(0.5)


struct MutTask[name: StringLiteral]:
    var value: Int

    fn __init__(out self, value: Int):
        self.value = value

    fn __call__(mut self):
        print("Running [", name, "]: Incrementing value", self.value)
        sleep(0.5)
        self.value += 1
        print("Finish [", name, "]: Value incremented. Now it's", self.value)


fn main():
    print("\n\nHey! Running Immutable Examples...")
    from move.task_groups.series.immutable import ImmSeriesTask as IS
    from move.task_groups.parallel.immutable import ImmParallelTask as IP

    init = MyTask["Initialize"]("Setting up...")
    load = MyTask["Load Data"]("Reading from some place...")
    find_min = MyTask["Min"]("Calculating...")
    find_max = MyTask["Max"]("Calculating...")
    find_mean = MyTask["Mean"]("Calculating...")
    find_median = MyTask["Median"]("Calculating...")
    merge_results = MyTask["Merge Results"]("Getting all together...")

    # Using Type syntax
    graph_1 = IS(
        init,
        load,
        IP(find_min, find_max, find_mean, find_median),
        merge_results,
    )
    print("[GRAPH 1]...")
    graph_1()

    # Airflow Syntax
    from move.task.immutable import ImmTask as IT

    graph_2 = (
        IT(init)
        >> load
        >> IT(find_min) + find_max + find_mean + find_median
        >> merge_results
    )
    print("[GRAPH 2]...")
    graph_2()

    # What about functions? Yes, those can be considered as ImmTasks.
    # But, you need to wrap those function into a FnTask type.
    # No arguments or captures are allowed, no returns. So it's not so useful.

    fn first_task():
        print("Initialize everything...")
        sleep(0.5)

    fn last_task():
        print("Finalize everything...")
        sleep(0.5)

    fn parallel1():
        print("Parallel 1...")
        sleep(0.5)

    fn parallel2():
        print("Parallel 2...")
        sleep(0.5)

    # NOTE: You need to do it here, because we need to have an Origin to be able to
    # use a reference to this functions. We can do it also by passing ownership, but I
    # don't want to do it right now. It will require to duplicate a lot of functions and
    # structs. But this is how I did for Mutable ones.

    from move.task.immutable import FnTask as Fn

    ft = Fn(first_task)
    p1 = Fn(parallel1)
    p2 = Fn(parallel2)
    lt = Fn(last_task)
    print("[ Function Graph ]...")
    fn_graph = IT(ft) >> IT(p1) + p2 >> lt
    fn_graph()

    # Hey, but these things are not useful, because you cannot mutate anything.
    # That's not true, but if you really need that, see mutable_examples.mojo
