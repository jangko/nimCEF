import cef/cef_task_api, cef/cef_types, nc_util, nc_types
include cef/cef_import

type
  # Implement this structure for asynchronous task execution. If the task is
  # posted successfully and if the associated message loop is still running then
  # the execute() function will be called on the target thread. If the task fails
  # to post then the task object may be destroyed on the source thread instead of
  # the target thread. For this reason be cautious when performing work in the
  # task object destructor.
  NCTask* = ref object of RootObj
    handler: cef_task

  # Structure that asynchronously executes tasks on the associated thread. It is
  # safe to call the functions of this structure on any thread.
  #
  # CEF maintains multiple internal threads that are used for handling different
  # types of tasks in different processes. The cef_thread_id_t definitions in
  # cef_types.h list the common CEF threads. Task runners are also available for
  # other CEF threads as appropriate (for example, V8 WebWorker threads).
  NCTaskRunner* = ptr cef_task_runner
  
method ExecuteTask*(self: NCTask) {.base.} =
  discard
  
proc execute_task(self: ptr cef_task) {.cef_callback.} =
  type_to_type(NCTask, self).ExecuteTask()

proc initialize_task(handler: ptr cef_task) =
  init_base(handler)
  handler.execute = execute_task

proc GetHandler*(self: NCTask): ptr cef_task =
  result = self.handler.addr
  
proc makeTask*(T: typedesc): auto =
  result = new(T)
  initialize_task(result.handler.addr)

# Returns true (1) if this object is pointing to the same task runner as
# |that| object.
proc IsSame*(self, that: NCTaskRunner): bool =
  add_ref(that)
  result = self.is_same(self, that) == 1.cint

# Returns true (1) if this task runner belongs to the current thread.
proc BelongsToCurrentThread*(self: NCTaskRunner): bool =
  result = self.belongs_to_current_thread(self) == 1.cint

# Returns true (1) if this task runner is for the specified CEF thread.
proc BelongsToThread*(self: NCTaskRunner, threadId: cef_thread_id): bool =
  result = self.belongs_to_thread(self, threadId) == 1.cint
  
# Post a task for execution on the thread associated with this task runner.
# Execution will occur asynchronously.
proc PostTask*(self: NCTaskRunner, task: NCTask): bool =
  add_ref(task.GetHandler())
  result = self.post_task(self, task.GetHandler()) == 1.cint

# Post a task for delayed execution on the thread associated with this task
# runner. Execution will occur asynchronously. Delayed tasks are not
# supported on V8 WebWorker threads and will be executed without the
# specified delay.

proc PostDelayedTask*(self: NCTaskRunner, task: NCTask, delay_ms: int64): bool =
  add_ref(task.GetHandler())
  result = self.post_delayed_task(self, task.GetHandler(), delay_ms) == 1.cint

# Returns the task runner for the current thread. Only CEF threads will have
# task runners. An NULL reference will be returned if this function is called
# on an invalid thread.
proc NCTaskRunnerGetForCurrentThread*(): NCTaskRunner =
  result = cef_task_runner_get_for_current_thread()

# Returns the task runner for the specified CEF thread.
proc NCTaskRunnerGetForThread*(threadId: cef_thread_id): NCTaskRunner =
  result = cef_task_runner_get_for_thread(threadId)

# Returns true (1) if called on the specified thread. Equivalent to using
# cef_task_tRunner::GetForThread(threadId)->belongs_to_current_thread().
proc NCCurrentlyOn*(threadId: cef_thread_id): bool =
  result = cef_currently_on(threadId) == 1.cint

# Post a task for execution on the specified thread. Equivalent to using
# cef_task_tRunner::GetForThread(threadId)->PostTask(task).
proc NCPostTask*(threadId: cef_thread_id, task: NCTask): bool =
  add_ref(task.GetHandler())
  result = cef_post_task(threadId, task.GetHandler()) == 1.cint

# Post a task for delayed execution on the specified thread. Equivalent to
# using cef_task_tRunner::GetForThread(threadId)->PostDelayedTask(task,
# delay_ms).
proc NCPostDelayedTask*(threadId: cef_thread_id, task: NCTask, delay_ms: int64): bool =
  add_ref(task.GetHandler())
  result = cef_post_delayed_task(threadId, task.GetHandler(), delay_ms) == 1.cint
  
template NC_REQUIRE_UI_THREAD*(): expr =
  doAssert(NCCurrentlyOn(TID_UI))
  
template NC_REQUIRE_IO_THREAD*(): expr =
  doAssert(NCCurrentlyOn(TID_IO))
  
template NC_REQUIRE_FILE_THREAD*(): expr =
  doAssert(NCCurrentlyOn(TID_FILE))
  
template NC_REQUIRE_RENDERER_THREAD*(): expr =
  doAssert(NCCurrentlyOn(TID_RENDERER))