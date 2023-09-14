searchData={"items":[{"type":"module","title":"MscmpSystLimiter","doc":"# MscmpSystLimiter - Token Bucket Rate Limiting\n\nAPI for establishing rate limits for usage of finite system resources.\n\nOnline, multi-user systems can be unintentionally overwhelmed by aggressive\nservice calls from external applications and systems or intentionally\nexploited by hostile actors seeking to defeat system protections though such\nactions as brute forcing user credentials or consuming all available computing\nresources of our application.  One approach to mitigating the dangers of\nresource exhaustion or persistent illicit information seeking attempts is to\nreject excessive calls to system services.\n\nThis component limits the rate at which targeted services can be called by\nany one caller to a level which preserves the availability of resources to\nall users of the system, or makes brute force information gathering\nprohibitively time intensive to would be attackers of the system.","ref":"MscmpSystLimiter.html"},{"type":"module","title":"Third Party Functionality - MscmpSystLimiter","doc":"This version of the `MscmpSystLimiter` component is primarily a wrapper\naround the third party [`Hammer`](https://github.com/ExHammer/hammer) library.\n`MscmpSystLimiter` offers a slightly different API to the wrapped library and\nchanges some return values to be more consistent with the Muse Systems Business\nManagement System standards and practices.  We also reuse and incorporate some\nof the documentation from these projects into our own documentation as\nappropriate.","ref":"MscmpSystLimiter.html#module-third-party-functionality"},{"type":"module","title":"Concepts - MscmpSystLimiter","doc":"MscmpSystLimiter implements a [\"Token Bucket\"](https://en.wikipedia.org/wiki/Token_bucket)\nrate limiting algorithm.  In a Token Bucket rate limit, for each user and\nrequest type a \"bucket\", called a \"Counter\" herein, with a finite\nnumber of tokens is created.  As requests are made the Counter is checked to\nsee if all the tokens are consumed and if not the request is allowed and a\ntoken consumed.  If there are no tokens available at request time, then the\nrequest is denied until the Counter expires.\n\nOver time, expired Counters are periodically deleted by the system.  Both the\nexpiry time and the cleanup schedule are configurable.","ref":"MscmpSystLimiter.html#module-concepts"},{"type":"function","title":"MscmpSystLimiter.check_rate/4","doc":"Checks if a Counter is within it's permissible rate and increments the Counter\nif it is within it's permissible rate.","ref":"MscmpSystLimiter.html#check_rate/4"},{"type":"function","title":"Parameters - MscmpSystLimiter.check_rate/4","doc":"* `counter_type` - an atom representing the kind of counter for which the\n  rate is being checked.\n\n  * `counter_id` - the specific Counter ID of the type.  For example if the\n  `counter_type` is `:user_login`, the `counter_id` value may be a value like\n  `user@email.domain` for the user's username.\n\n  * `scale_ms` - the time in milliseconds of the rate window.  For example,\n  for the rate limit of 3 tries in one minute the `scale_ms` value is set to\n  60,000 milliseconds for one minute.\n\n  * `limit` - the number of attempts allowed with the `scale_ms` duration.  In\n  the example of 3 tries in one minute, the `limit` value is 3.","ref":"MscmpSystLimiter.html#check_rate/4-parameters"},{"type":"function","title":"Example - MscmpSystLimiter.check_rate/4","doc":"iex> MscmpSystLimiter.check_rate(:check_rate_counter, \"id1\", 60_000, 3)\n    {:allow, 1}\n    iex> MscmpSystLimiter.check_rate(:check_rate_counter, \"id1\", 60_000, 3)\n    {:allow, 2}\n    iex> MscmpSystLimiter.check_rate(:check_rate_counter, \"id1\", 60_000, 3)\n    {:allow, 3}\n    iex> MscmpSystLimiter.check_rate(:check_rate_counter, \"id1\", 60_000, 3)\n    {:deny, 3}","ref":"MscmpSystLimiter.html#check_rate/4-example"},{"type":"function","title":"MscmpSystLimiter.check_rate_with_increment/5","doc":"Checks the rate same as `MscmpSystLimiter.check_rate/4`, but allows for a\nvariable increment to be set for the call.","ref":"MscmpSystLimiter.html#check_rate_with_increment/5"},{"type":"function","title":"Parameters - MscmpSystLimiter.check_rate_with_increment/5","doc":"* `counter_type` - an atom representing the kind of counter for which the\n  rate is being checked.\n\n  * `counter_id` - the specific Counter ID of the type.  For example if the\n  `counter_type` is `:user_login`, the `counter_id` value may be a value like\n  `user@email.domain` for the user's username.\n\n  * `scale_ms` - the time in milliseconds of the rate window.  For example,\n  for the rate limit of 3 tries in one minute the `scale_ms` value is set to\n  60,000 milliseconds for one minute.\n\n  * `limit` - the number of attempts allowed with the `scale_ms` duration.  In\n  the example of 3 tries in one minute, the `limit` value is 3.","ref":"MscmpSystLimiter.html#check_rate_with_increment/5-parameters"},{"type":"function","title":"Example - MscmpSystLimiter.check_rate_with_increment/5","doc":"iex> MscmpSystLimiter.check_rate_with_increment(\n    ...>   :check_with_increment,\n    ...>   \"id1\",\n    ...>   60_000,\n    ...>   10,\n    ...>   7)\n    {:allow, 7}\n    iex> MscmpSystLimiter.check_rate_with_increment(\n    ...>   :check_with_increment,\n    ...>   \"id1\",\n    ...>   60_000,\n    ...>   10,\n    ...>   2)\n    {:allow, 9}\n    iex> MscmpSystLimiter.check_rate(:check_with_increment, \"id1\", 60_000, 10)\n    {:allow, 10}","ref":"MscmpSystLimiter.html#check_rate_with_increment/5-example"},{"type":"function","title":"MscmpSystLimiter.delete_counters/2","doc":"Deletes a counter from the system.","ref":"MscmpSystLimiter.html#delete_counters/2"},{"type":"function","title":"Parameters - MscmpSystLimiter.delete_counters/2","doc":"* `counter_type` - an atom representing the kind of counter which is to be\n  deleted.\n\n  * `counter_id` - the specific Counter ID of the type.  For example if the\n  `counter_type` is `:user_login`, the `counter_id` value may be a value like\n  `user@email.domain` for the user's username.","ref":"MscmpSystLimiter.html#delete_counters/2-parameters"},{"type":"function","title":"Example - MscmpSystLimiter.delete_counters/2","doc":"iex> MscmpSystLimiter.check_rate(:delete_test_counter, \"id1\", 60_000, 3)\n    {:allow, 1}\n    iex> MscmpSystLimiter.delete_counters(:delete_test_counter, \"id1\")\n    {:ok, 1}","ref":"MscmpSystLimiter.html#delete_counters/2-example"},{"type":"function","title":"MscmpSystLimiter.get_check_rate_function/3","doc":"Returns an anonymous function to simplify calls to check the rate for a\nspecific counter type.\n\nThe returned function avoids requiring the parameters that are common between\ncalls from being constantly supplied.  The only parameter that the returned\nfunction requires is the `counter_id` value of the specific counter of the\ntype to test; all other parameters typically required by\n`MscmpSystLimiter.check_rate/4` are captured by the returned closure.","ref":"MscmpSystLimiter.html#get_check_rate_function/3"},{"type":"function","title":"Parameters - MscmpSystLimiter.get_check_rate_function/3","doc":"* `counter_type` - an atom representing the kind of counter that the\n  returned function will be set to check.\n\n  * `scale_ms` - the time in milliseconds of the rate window.  For example,\n  for the rate limit of 3 tries in one minute the `scale_ms` value is set to\n  60,000 milliseconds for one minute.\n\n  * `limit` - the number of attempts allowed with the `scale_ms` duration.  In\n  the example of 3 tries in one minute, the `limit` value is 3.","ref":"MscmpSystLimiter.html#get_check_rate_function/3-parameters"},{"type":"function","title":"Example - MscmpSystLimiter.get_check_rate_function/3","doc":"Note that The returned anonymous function is equivalent to making a call to\nthe more verbose `MscmpSystLimiter.check_rate/4`:\n\n    iex> my_check_rate_function =\n    ...>   MscmpSystLimiter.get_check_rate_function(\n    ...>     :example_counter_get_func,\n    ...>     60_000,\n    ...>     3)\n    iex> my_check_rate_function.(\"id1\")\n    {:allow, 1}\n    iex> MscmpSystLimiter.check_rate(\n    ...>   :example_counter_get_func,\n    ...>   \"id1\",\n    ...>   60_000,\n    ...>   3)\n    {:allow, 2}\n    iex> my_check_rate_function.(\"id1\")\n    {:allow, 3}","ref":"MscmpSystLimiter.html#get_check_rate_function/3-example"},{"type":"function","title":"MscmpSystLimiter.get_counter_name/2","doc":"Creates a canonical name for each unique counter.","ref":"MscmpSystLimiter.html#get_counter_name/2"},{"type":"function","title":"Parameters - MscmpSystLimiter.get_counter_name/2","doc":"* `counter_type` - an atom representing the kind of counter being created.\n\n  * `counter_id` - a value unique to the `counter_type` which identifies a\n  specific counter.","ref":"MscmpSystLimiter.html#get_counter_name/2-parameters"},{"type":"function","title":"Example - MscmpSystLimiter.get_counter_name/2","doc":"iex> MscmpSystLimiter.get_counter_name(:example_counter_name, \"123\")\n    \"example_counter_name_123\"","ref":"MscmpSystLimiter.html#get_counter_name/2-example"},{"type":"function","title":"MscmpSystLimiter.inspect_counter/4","doc":"Retrieves data about a currently used counter without counting towards the limit.","ref":"MscmpSystLimiter.html#inspect_counter/4"},{"type":"function","title":"Parameters - MscmpSystLimiter.inspect_counter/4","doc":"* `counter_type` - an atom representing the kind of counter which to inspect.\n\n  * `counter_id` - the specific Counter ID of the type.  For example if the\n  `counter_type` is `:user_login`, the `counter_id` value may be a value like\n  `user@email.domain` for the user's username.\n\n  * `scale_ms` - the time in milliseconds of the rate window.  For example,\n  for the rate limit of 3 tries in one minute the `scale_ms` value is set to\n  60,000 milliseconds for one minute.\n\n  * `limit` - the number of attempts allowed with the `scale_ms` duration.  In\n  the example of 3 tries in one minute, the `limit` value is 3.","ref":"MscmpSystLimiter.html#inspect_counter/4-parameters"},{"type":"module","title":"MscmpSystLimiter.Types","doc":"Defines public types for use with the MscmpSystLimiter module.","ref":"MscmpSystLimiter.Types.html"},{"type":"type","title":"MscmpSystLimiter.Types.counter_id/0","doc":"A unique identifier for the specific counter within the requested counter\ntype.","ref":"MscmpSystLimiter.Types.html#t:counter_id/0"},{"type":"type","title":"MscmpSystLimiter.Types.counter_name/0","doc":"The name of the counter which is derived from the counter type and counter\nid values.","ref":"MscmpSystLimiter.Types.html#t:counter_name/0"},{"type":"type","title":"MscmpSystLimiter.Types.counter_table_name/0","doc":"The type of value expected for the table which holds the counters.","ref":"MscmpSystLimiter.Types.html#t:counter_table_name/0"},{"type":"type","title":"MscmpSystLimiter.Types.counter_type/0","doc":"The kind of activity being rate limited.\n\nFor example, a counter type might be `:login_attempt`.","ref":"MscmpSystLimiter.Types.html#t:counter_type/0"}],"content_type":"text/markdown"}