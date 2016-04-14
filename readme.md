# nimCEF

Chromium Embedded Framework(CEF3) wrapper

---

nimCEF consist of two parts:

* First part: nimCEF is a thin wrapper for CEF3 written in Nim.
Basically, nimCEF is CEF3 C API translated to Nim, therefore
if you know how to use CEF3 C API, using **First part** is not much different.

* Second part: Convenience layer added on top of C style API to ease
the development in Nim style. Nim native datatypes will be used whenever possible.
And many of the ref-count related issues already handled for you.

---

###Translation status(CEF3 ver 2623):

| No | Items                 | Win32    | Linux32 | Win64    | Linux64 | Mac64    | Nim Ver |
|----|-----------------------|----------|---------|----------|---------|----------|---------|
| 1  | CEF3 C API            | complete | 98%     | complete | 98%     | 90%      | 0.13.0  |
| 2  | CEF3 C API example    | yes      | no      | yes      | no      | no       | 0.13.0  |
| 3  | Simple Client Example | yes      | no      | yes      | no      | no       | 0.13.0  |
| 4  | CefClient Example     | no       | no      | no       | no      | no       | 0.13.0  |
| 5  | Convenience Layer     | 30%      | 25%     | 30%      | 25%     | no       | 0.13.0  |