import cef_base_api
include cef_import

type
  # Implement this structure for asynchronous task execution. If the task is
  # posted successfully and if the associated message loop is still running then
  # the execute() function will be called on the target thread. If the task fails
  # to post then the task object may be destroyed on the source thread instead of
  # the target thread. For this reason be cautious when performing work in the
  # task object destructor.
  cef_task* = object
    base*: cef_base
  
    # Method that will be executed on the target thread.
    execute*: proc(self: ptr cef_task) {.cef_callback.}

  # Structure that asynchronously executes tasks on the associated thread. It is
  # safe to call the functions of this structure on any thread.
  #
  # CEF maintains multiple internal threads that are used for handling different
  # types of tasks in different processes. The cef_thread_id_t definitions in
  # cef_types.h list the common CEF threads. Task runners are also available for
  # other CEF threads as appropriate (for example, V8 WebWorker threads).
  cef_task_runner* = object
    base*: cef_base
  
    # Returns true (1) if this object is pointing to the same task runner as
    # |that| object.
    is_same*: proc(self, that: ptr cef_task_runner): cint {.cef_callback.}
  
    # Returns true (1) if this task runner belongs to the current thread.
    belongs_to_current_thread*: proc(self: ptr cef_task_runner): cint {.cef_callback.}
  
    # Returns true (1) if this task runner is for the specified CEF thread.
    belongs_to_thread*: proc(self: ptr cef_task_runner,
       threadId: cef_thread_id): cint {.cef_callback.}
  
    # Post a task for execution on the thread associated with this task runner.
    # Execution will occur asynchronously.
    post_task*: proc(self: ptr cef_task_runner,
      task: ptr cef_task): cint {.cef_callback.}
  
    # Post a task for delayed execution on the thread associated with this task
    # runner. Execution will occur asynchronously. Delayed tasks are not
    # supported on V8 WebWorker threads and will be executed without the
    # specified delay.
    
    post_delayed_task*: proc(self: ptr cef_task_runner,
      task: ptr cef_task, delay_ms: int64): cint {.cef_callback.}

# Returns the task runner for the current thread. Only CEF threads will have
# task runners. An NULL reference will be returned if this function is called
# on an invalid thread.
proc cef_task_runner_get_for_current_thread*(): ptr cef_task_runner {.cef_import.}

# Returns the task runner for the specified CEF thread.
proc cef_task_runner_get_for_thread*(threadId: cef_thread_id): ptr cef_task_runner {.cef_import.}

# Returns true (1) if called on the specified thread. Equivalent to using
# cef_task_tRunner::GetForThread(threadId)->belongs_to_current_thread().
proc cef_currently_on*(threadId: cef_thread_id): cint {.cef_import.}

# Post a task for execution on the specified thread. Equivalent to using
# cef_task_tRunner::GetForThread(threadId)->PostTask(task).
proc cef_post_task*(threadId: cef_thread_id, task: ptr cef_task): cint {.cef_import.}

# Post a task for delayed execution on the specified thread. Equivalent to
# using cef_task_tRunner::GetForThread(threadId)->PostDelayedTask(task,
# delay_ms).
proc cef_post_delayed_task*(threadId: cef_thread_id, task: ptr cef_task, delay_ms: int64): cint {.cef_import.}