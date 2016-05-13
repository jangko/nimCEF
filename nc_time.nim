import cef/cef_time_api, times

type
  NCTime* = object
    year*: int          # Four digit year "2007"
    month*: int         # 1-based month (values 1 = January, etc.)
    day_of_week*: int   # 0-based day of week (0 = Sunday, etc.)
    day_of_month*: int  # 1-based day of month (1-31)
    hour*: int          # Hour within the current day (0-23)
    minute*: int        # Minute within the current hour (0-59)
    second*: int        # Second within the current minute (0-59 plus leap
                        # seconds which may take it up to 60).
    millisecond*: int   # Milliseconds within the current second (0-999)

proc to_cef*(nt: NCTime): cef_time =
  result.year = nt.year.cint
  result.month = nt.month.cint
  result.day_of_week = nt.day_of_week.cint
  result.day_of_month = nt.day_of_month.cint
  result.hour = nt.hour.cint
  result.minute = nt.minute.cint
  result.second = nt.second.cint
  result.millisecond = nt.millisecond.cint

proc to_nim*(ct: cef_time): NCTime =
  result.year = ct.year.int
  result.month = ct.month.int
  result.day_of_week = ct.day_of_week.int
  result.day_of_month = ct.day_of_month.int
  result.hour = ct.hour.int
  result.minute = ct.minute.int
  result.second = ct.second.int
  result.millisecond = ct.millisecond.int

# Converts cef_time_t to/from time_t. Returns true (1) on success and false (0)
# on failure.
proc toTime*(ntime: NCTime, time: var Time): bool =
  var ct = to_cef(ntime)
  result = cef_time_to_timet(ct.addr, time) == 1.cint

proc fromTime*(ntime: var NCTime, time: Time): bool =
  var ct: cef_time
  result = cef_time_from_timet(time, ct) == 1.cint
  ntime = to_nim(ct)

# Converts cef_time_t to/from a double which is the number of seconds since
# epoch (Jan 1, 1970). Webkit uses this format to represent time. A value of 0
# means "not initialized". Returns true (1) on success and false (0) on
# failure.
proc toFloat*(ntime: NCTime, time: var float64): bool =
  var ct = to_cef(ntime)
  var res: float64
  result = cef_time_to_doublet(ct.addr, res) == 1.cint
  time = res

proc fromFloat*(ntime: var NCTime, time: float64): bool =
  var ct: cef_time
  result = cef_time_from_doublet(time.cdouble, ct) == 1.cint
  ntime = to_nim(ct)

# Retrieve the current system time.
proc Now*(ntime: var NCTime): bool =
  var ct: cef_time
  result = cef_time_now(ct) == 1.cint
  ntime = to_nim(ct)

# Retrieve the delta in milliseconds between two time values.
proc Delta*(ntime1, ntime2: NCTime, delta: var uint64): bool =
  var ct1 = to_cef(ntime1)
  var ct2 = to_cef(ntime2)
  result = cef_time_delta(ct1.addr, ct2.addr, delta) == 1.cint