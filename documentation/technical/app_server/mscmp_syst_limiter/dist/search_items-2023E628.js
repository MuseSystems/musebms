searchNodes=[{"doc":"MscmpSystLimiter - Token Bucket Rate Limiting API for establishing rate limits for usage of finite system resources. Online, multi-user systems can be unintentionally overwhelmed by aggressive service calls from external applications and systems or intentionally exploited by hostile actors seeking to defeat system protections though such actions as brute forcing user credentials or consuming all available computing resources of our application. One approach to mitigating the dangers of resource exhaustion or persistent illicit information seeking attempts is to reject excessive calls to system services. This component limits the rate at which targeted services can be called by any one caller to a level which preserves the availability of resources to all users of the system, or makes brute force information gathering prohibitively time intensive to would be attackers of the system. Third Party Functionality This version of the MscmpSystLimiter component is primarily a wrapper around the third party Hammer library. MscmpSystLimiter offers a slightly different API to the wrapped library and changes some return values to be more consistent with the Muse Systems Business Management System standards and practices. We also reuse and incorporate some of the documentation from these projects into our own documentation as appropriate. Concepts MscmpSystLimiter implements a &quot;Token Bucket&quot; rate limiting algorithm. In a Token Bucket rate limit, for each user and request type a &quot;bucket&quot;, called a &quot;Counter&quot; herein, with a finite number of tokens is created. As requests are made the Counter is checked to see if all the tokens are consumed and if not the request is allowed and a token consumed. If there are no tokens available at request time, then the request is denied until the Counter expires. Over time, expired Counters are periodically deleted by the system. Both the expiry time and the cleanup schedule are configurable.","ref":"MscmpSystLimiter.html","title":"MscmpSystLimiter","type":"module"},{"doc":"Checks if a Counter is within it's permissible rate and increments the Counter if it is within it's permissible rate. Parameters counter_type - an atom representing the kind of counter for which the rate is being checked. counter_id - the specific Counter ID of the type. For example if the counter_type is :user_login , the counter_id value may be a value like user@email.domain for the user's username. scale_ms - the time in milliseconds of the rate window. For example, for the rate limit of 3 tries in one minute the scale_ms value is set to 60,000 milliseconds for one minute. limit - the number of attempts allowed with the scale_ms duration. In the example of 3 tries in one minute, the limit value is 3. Example iex&gt; MscmpSystLimiter . check_rate ( :check_rate_counter , &quot;id1&quot; , 60_000 , 3 ) { :allow , 1 } iex&gt; MscmpSystLimiter . check_rate ( :check_rate_counter , &quot;id1&quot; , 60_000 , 3 ) { :allow , 2 } iex&gt; MscmpSystLimiter . check_rate ( :check_rate_counter , &quot;id1&quot; , 60_000 , 3 ) { :allow , 3 } iex&gt; MscmpSystLimiter . check_rate ( :check_rate_counter , &quot;id1&quot; , 60_000 , 3 ) { :deny , 3 }","ref":"MscmpSystLimiter.html#check_rate/4","title":"MscmpSystLimiter.check_rate/4","type":"function"},{"doc":"Checks the rate same as MscmpSystLimiter.check_rate/4 , but allows for a variable increment to be set for the call. Parameters counter_type - an atom representing the kind of counter for which the rate is being checked. counter_id - the specific Counter ID of the type. For example if the counter_type is :user_login , the counter_id value may be a value like user@email.domain for the user's username. scale_ms - the time in milliseconds of the rate window. For example, for the rate limit of 3 tries in one minute the scale_ms value is set to 60,000 milliseconds for one minute. limit - the number of attempts allowed with the scale_ms duration. In the example of 3 tries in one minute, the limit value is 3. Example iex&gt; MscmpSystLimiter . check_rate_with_increment ( ...&gt; :check_with_increment , ...&gt; &quot;id1&quot; , ...&gt; 60_000 , ...&gt; 10 , ...&gt; 7 ) { :allow , 7 } iex&gt; MscmpSystLimiter . check_rate_with_increment ( ...&gt; :check_with_increment , ...&gt; &quot;id1&quot; , ...&gt; 60_000 , ...&gt; 10 , ...&gt; 2 ) { :allow , 9 } iex&gt; MscmpSystLimiter . check_rate ( :check_with_increment , &quot;id1&quot; , 60_000 , 10 ) { :allow , 10 }","ref":"MscmpSystLimiter.html#check_rate_with_increment/5","title":"MscmpSystLimiter.check_rate_with_increment/5","type":"function"},{"doc":"Deletes a counter from the system. Parameters counter_type - an atom representing the kind of counter which is to be deleted. counter_id - the specific Counter ID of the type. For example if the counter_type is :user_login , the counter_id value may be a value like user@email.domain for the user's username. Example iex&gt; MscmpSystLimiter . check_rate ( :delete_test_counter , &quot;id1&quot; , 60_000 , 3 ) { :allow , 1 } iex&gt; MscmpSystLimiter . delete_counters ( :delete_test_counter , &quot;id1&quot; ) { :ok , 1 }","ref":"MscmpSystLimiter.html#delete_counters/2","title":"MscmpSystLimiter.delete_counters/2","type":"function"},{"doc":"Returns an anonymous function to simplify calls to check the rate for a specific counter type. The returned function avoids requiring the parameters that are common between calls from being constantly supplied. The only parameter that the returned function requires is the counter_id value of the specific counter of the type to test; all other parameters typically required by MscmpSystLimiter.check_rate/4 are captured by the returned closure. Parameters counter_type - an atom representing the kind of counter that the returned function will be set to check. scale_ms - the time in milliseconds of the rate window. For example, for the rate limit of 3 tries in one minute the scale_ms value is set to 60,000 milliseconds for one minute. limit - the number of attempts allowed with the scale_ms duration. In the example of 3 tries in one minute, the limit value is 3. Example Note that The returned anonymous function is equivalent to making a call to the more verbose MscmpSystLimiter.check_rate/4 : iex&gt; my_check_rate_function = ...&gt; MscmpSystLimiter . get_check_rate_function ( ...&gt; :example_counter_get_func , ...&gt; 60_000 , ...&gt; 3 ) iex&gt; my_check_rate_function . ( &quot;id1&quot; ) { :allow , 1 } iex&gt; MscmpSystLimiter . check_rate ( ...&gt; :example_counter_get_func , ...&gt; &quot;id1&quot; , ...&gt; 60_000 , ...&gt; 3 ) { :allow , 2 } iex&gt; my_check_rate_function . ( &quot;id1&quot; ) { :allow , 3 }","ref":"MscmpSystLimiter.html#get_check_rate_function/3","title":"MscmpSystLimiter.get_check_rate_function/3","type":"function"},{"doc":"Creates a canonical name for each unique counter. Parameters counter_type - an atom representing the kind of counter being created. counter_id - a value unique to the counter_type which identifies a specific counter. Example iex&gt; MscmpSystLimiter . get_counter_name ( :example_counter_name , &quot;123&quot; ) &quot;example_counter_name_123&quot;","ref":"MscmpSystLimiter.html#get_counter_name/2","title":"MscmpSystLimiter.get_counter_name/2","type":"function"},{"doc":"Retrieves data about a currently used counter without counting towards the limit. Parameters counter_type - an atom representing the kind of counter which to inspect. counter_id - the specific Counter ID of the type. For example if the counter_type is :user_login , the counter_id value may be a value like user@email.domain for the user's username. scale_ms - the time in milliseconds of the rate window. For example, for the rate limit of 3 tries in one minute the scale_ms value is set to 60,000 milliseconds for one minute. limit - the number of attempts allowed with the scale_ms duration. In the example of 3 tries in one minute, the limit value is 3.","ref":"MscmpSystLimiter.html#inspect_counter/4","title":"MscmpSystLimiter.inspect_counter/4","type":"function"},{"doc":"Defines public types for use with the MscmpSystLimiter module.","ref":"MscmpSystLimiter.Types.html","title":"MscmpSystLimiter.Types","type":"module"},{"doc":"A unique identifier for the specific counter within the requested counter type.","ref":"MscmpSystLimiter.Types.html#t:counter_id/0","title":"MscmpSystLimiter.Types.counter_id/0","type":"type"},{"doc":"The name of the counter which is derived from the counter type and counter id values.","ref":"MscmpSystLimiter.Types.html#t:counter_name/0","title":"MscmpSystLimiter.Types.counter_name/0","type":"type"},{"doc":"The type of value expected for the table which holds the counters.","ref":"MscmpSystLimiter.Types.html#t:counter_table_name/0","title":"MscmpSystLimiter.Types.counter_table_name/0","type":"type"},{"doc":"The kind of activity being rate limited. For example, a counter type might be :login_attempt .","ref":"MscmpSystLimiter.Types.html#t:counter_type/0","title":"MscmpSystLimiter.Types.counter_type/0","type":"type"}]