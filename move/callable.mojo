trait Callable:
    """The struct should contain a fn __call__ method.

    ```mojo
    trait Callable:
        fn __call__(self):
            ...
    ```
    """

    fn __call__(self):
        ...


trait CallableMutable:
    """The struct should contain a fn __call__ method.

    ```mojo
    trait CallableMutable:
        fn __call__(mut self):
            ...
    ```
    """

    fn __call__(mut self):
        ...


trait CallableMovable(Callable, Movable):
    """A `Callable` + `Movable`.

    ```mojo
    trait CallableMovable:
        fn __moveinit__(out self, owned existing: Self):
            ...

        fn __call__(self):
            ...
    ```
    """

    ...


trait CallableMutableMovable(CallableMutable, Movable):
    """A `CallableMutable` + `Movable`.

    ```mojo
    trait CallableMutableMovable:
        fn __moveinit__(out self, owned existing: Self):
            ...

        fn __call__(mut self):
            ...
    ```
    """

    ...


trait CallableDefaultable(Callable, Defaultable):
    """A `Callable` + `Defaultable`.

    ```mojo
    trait CallableDefaultable:
        fn __init__(out self):
            ...

        fn __call__(self):
            ...
    ```
    """

    ...


struct CallablePack[origin: Origin, *Ts: Callable](Copyable):
    """Stores a reference variadic pack of `Callable` structs.

    The storage it's just the `VariadicPack` inner _value.

    If you are getting a variadic set of `Callable` arguments, you can store them in
    a CallablePack. Those can be used later, even out of the function. We use a lifetime
    hack to point to the _value lifetime instead of the args lifetime.

    ```mojo
    from move.callable import CallablePack, Callable

    struct MyTask(Callable):
        fn __init__(out self):
            pass

        fn __call__(self):
            print("Running my call...")

    # hack to point to the _value lifetime instead of the args lifetime.
    fn store_value[*Ts: Callable](*args: *Ts) -> CallablePack[__origin_of(args._value), *Ts]:
        return rebind[CallablePack[__origin_of(args._value), *Ts]](CallablePack(args._value))


    task = MyTask()
    cpacks = store_value(task)

    # Use the task here
    cpacks[0]()

    ```
    """

    alias _mlir_type = VariadicPack[origin, Callable, *Ts]._mlir_type

    var storage: Self._mlir_type

    @implicit
    fn __init__(out self, storage: Self._mlir_type):
        self.storage = storage

    fn __copyinit__(out self, other: Self):
        self.storage = other.storage

    fn __getitem__[i: Int](self) -> ref [origin] Ts[i.value]:
        value = __mlir_op.`lit.ref.pack.extract`[index = i.value](self.storage)
        return __get_litref_as_mvalue(value)
