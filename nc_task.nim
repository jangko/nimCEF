import cef/cef_types, nc_util, nc_types
include cef/cef_import

# Implement this structure for asynchronous task execution. If the task is
# posted successfully and if the associated message loop is still running then
# the execute() function will be called on the target thread. If the task fails
# to post then the task object may be destroyed on the source thread instead of
# the target thread. For this reason be cautious when performing work in the
# task object destructor.
wrapAPI(NCTask, cef_task)
    
# Structure that asynchronously executes tasks on the associated thread. It is
# safe to call the functions of this structure on any thread.
#
# CEF maintains multiple internal threads that are used for handling different
# types of tasks in different processes. The cef_thread_id_t definitions in
# cef_types.h list the common CEF threads. Task runners are also available for
# other CEF threads as appropriate (for example, V8 WebWorker threads).
wrapAPI(NCTaskRunner, cef_task_runner, false)

#method ExecuteTask*(self: NCTask) {.base.} =
#  discard
#
#proc execute_task(self: ptr cef_task) {.cef_callback.} =
#  type_to_type(NCTask, self).ExecuteTask()
#
#proc initialize_task(handler: ptr cef_task) =
#  init_base(handler)
#  handler.execute = execute_task
#
#proc GetHandler*(self: NCTask): ptr cef_task {.inline.} =
#  result = self.handler.addr
#
#proc makeTask*(T: typedesc): auto =
#  result = new(T)
#  initialize_task(result.handler.addr)

# Returns true (1) if this object is pointing to the same task runner as
# |that| object.
proc IsSame*(self, that: NCTaskRunner): bool =
  self.wrapCall(is_same, result, that)
  
# Returns true (1) if this task runner belongs to the current thread.
proc BelongsToCurrentThread*(self: NCTaskRunner): bool =
  self.wrapCall(belongs_to_current_thread, result)

# Returns true (1) if this task runner is for the specified CEF thread.
proc BelongsToThread*(self: NCTaskRunner, threadId: cef_thread_id): bool =
  self.wrapCall(belongs_to_thread, result, threadId)

# Post a task for execution on the thread associated with this task runner.
# Execution will occur asynchronously.
proc PostTask*(self: NCTaskRunner, task: NCTask): bool =
  self.wrapCall(post_task, result, task)

# Post a task for delayed execution on the thread associated with this task
# runner. Execution will occur asynchronously. Delayed tasks are not
# supported on V8 WebWorker threads and will be executed without the
# specified delay.
proc PostDelayedTask*(self: NCTaskRunner, task: NCTask, delay_ms: int64): bool =
  self.wrapCall(post_delayed_task, result, task, delay_ms)

# Returns the task runner for the current thread. Only CEF threads will have
# task runners. An NULL reference will be returned if this function is called
# on an invalid thread.
proc NCTaskRunnerGetForCurrentThread*(): NCTaskRunner =
  wrapProc(cef_task_runner_get_for_current_thread, result)

# Returns the task runner for the specified CEF thread.
proc NCTaskRunnerGetForThread*(threadId: cef_thread_id): NCTaskRunner =
  wrapProc(cef_task_runner_get_for_thread, result, threadId)

# Returns true (1) if called on the specified thread. Equivalent to using
# cef_task_tRunner::GetForThread(threadId)->belongs_to_current_thread().
proc NCCurrentlyOn*(threadId: cef_thread_id): bool =
  wrapProc(cef_currently_on, result, threadId)

# Post a task for execution on the specified thread. Equivalent to using
# cef_task_tRunner::GetForThread(threadId)->PostTask(task).
proc NCPostTask*(threadId: cef_thread_id, task: NCTask): bool =
  wrapProc(cef_post_task, result, threadId, task)

# Post a task for delayed execution on the specified thread. Equivalent to
# using cef_task_tRunner::GetForThread(threadId)->PostDelayedTask(task,
# delay_ms).
proc NCPostDelayedTask*(threadId: cef_thread_id, task: NCTask, delay_ms: int64): bool =
  wrapProc(cef_post_delayed_task, result, threadId, task, delay_ms)

template NC_REQUIRE_UI_THREAD*(): expr =
  doAssert(NCCurrentlyOn(TID_UI))

template NC_REQUIRE_IO_THREAD*(): expr =
  doAssert(NCCurrentlyOn(TID_IO))

template NC_REQUIRE_FILE_THREAD*(): expr =
  doAssert(NCCurrentlyOn(TID_FILE))

template NC_REQUIRE_RENDERER_THREAD*(): expr =
  doAssert(NCCurrentlyOn(TID_RENDERER))