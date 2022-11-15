searchNodes=[{"doc":"API for establishing rate limits for usage of finite system resources. Online, multi-user systems can be unintentionally overwhelmed by aggressive service calls from external applications and systems or intentionally exploited by hostile actors seeking to defeat system protections though such actions as brute forcing user credentials or consuming all available computing resources of our application. One approach to mitigating the dangers of resource exhaustion or persistent illicit information seeking attempts is to reject excessive calls to system services. This component limits the rate at which targeted services can be called by any one caller to a level which preserves the availability of resources to all users of the system, or makes brute force information gathering prohibitively time intensive to would be attackers of the system. Third Party Functionality This version of the MsbmsSystRateLimiter component is primarily a wrapper around the third party Hammer and Hammer.Backend.Mnesia libraries. MsbmsSystRateLimiter offers a slightly different API to the wrapped libraries and changes some return values to be more consistent with the Muse Systems Business Management System standards and practices. We also reuse and incorporate some of the documentation from these projects into our own documentation as appropriate. Concepts MsbmSystRateLimiter implements a &quot;Token Bucket&quot; rate limiting algorithm. In a Token Bucket rate limit, for each user and request type a &quot;bucket&quot;, called a &quot;Counter&quot; herein, with a finite number of tokens is created. As requests are made the Counter is checked to see if all the tokens are consumed and if not the request is allowed and a token consumed. If there are no tokens available at request time, then the request is denied until the Counter expires. Over time, expired Counters are periodically deleted by the system. Both the expiry time and the cleanup schedule are configurable. Setup for Use Using this component assumes certain setups and configurations are performed by the client application: Configure MsbmsSystRateLimiter - The rate limiter allows several configuration points to be set to customize the behavior of service. Add: config :msbms_syst_rate_limiter , expiry_ms : 60_000 * 60 * 2 , cleanup_interval_ms : 60_000 * 10 , table_name : :msbms_syst_rate_limiter_counters with the desired values to config.exs . The values expressed in the example are also the defaults for these values if the configuration is not provided. The configuration points are. expiry_ms - the life time in milliseconds of any single Counter. This should be longer than the life of the longest bucket that will be created. A shorter value could result in an active counter being deleted prior to becoming inactive. cleanup_interval_ms - the time in milliseconds to wait between sweeps of the stale Counter cleaner. During a sweep any Counter past its expiry time (see expiry_ms ) will be purged from the system. table_name - the name of the backend database table to use for tracking counters. Typically this value should be allowed to default ( :msbms_syst_rate_limiter_counters ) unless there's a compelling reason to do otherwise. Setup Mnesia - MsbmsSystRateLimiter keeps its counters in the Mnesia database allowing for distribution of the rate limit counters across nodes. MsbmsSystRaleLimiter expects the client application to have setup and called :mnesia.create_schema/1 prior to trying to use the provided services. Initialize the Counter Table - Once the Mnesia is configured and running, the Mnesia table which will hold the counters must be created if it doesn't already exist. There are two ways to do this: 1) add a start phase to the client application mix.exs or call a function which creates the Mnesia table if it doesn't exist. Add a Start Phase - In the mix.exs applications specification section add a :post_mnesia_setup start phase. Example: def application do [ extra_applications : [ :logger , :mnesia ] start_phases : [ { :post_mnesia_setup , [ mnesia_table_args : [ ] ] } ] ] end note that an optional mnesia_table_args value may be set to further configure behavior of the mnesia table. mnesia_table_args is a Keyword List which simply gets passed to :mnesia.create_table/2 as the Arg parameter. see the Erlang docs for more. Call Table Creation Function - If adding a start_phases definition to the application specification is not desirable, the table creation can also be completed by explicitly calling MsbmsSystRateLimiter.init_rate_limiter/1 function.","ref":"MsbmsSystRateLimiter.html","title":"MsbmsSystRateLimiter","type":"module"},{"doc":"Checks if a Counter is within it's permissible rate and increments the Counter if it is within it's permissible rate. Parameters counter_type - an atom representing the kind of counter for which the rate is being checked. counter_id - the specific Counter ID of the type. For example if the counter_type is :user_login , the counter_id value may be a value like user@email.domain for the user's username. scale_ms - the time in milliseconds of the rate window. For example, for the rate limit of 3 tries in one minute the scale_ms value is set to 60,000 milliseconds for one minute. limit - the number of attempts allowed with the scale_ms duration. In the example of 3 tries in one minute, the limit value is 3. Example iex&gt; MsbmsSystRateLimiter . check_rate ( :check_rate_counter , &quot;id1&quot; , 60_000 , 3 ) { :allow , 1 } iex&gt; MsbmsSystRateLimiter . check_rate ( :check_rate_counter , &quot;id1&quot; , 60_000 , 3 ) { :allow , 2 } iex&gt; MsbmsSystRateLimiter . check_rate ( :check_rate_counter , &quot;id1&quot; , 60_000 , 3 ) { :allow , 3 } iex&gt; MsbmsSystRateLimiter . check_rate ( :check_rate_counter , &quot;id1&quot; , 60_000 , 3 ) { :deny , 3 }","ref":"MsbmsSystRateLimiter.html#check_rate/4","title":"MsbmsSystRateLimiter.check_rate/4","type":"function"},{"doc":"Checks the rate same as MsbmsSystRateLimiter.check_rate/4 , but allows for a variable increment to be set for the call. Parameters counter_type - an atom representing the kind of counter for which the rate is being checked. counter_id - the specific Counter ID of the type. For example if the counter_type is :user_login , the counter_id value may be a value like user@email.domain for the user's username. scale_ms - the time in milliseconds of the rate window. For example, for the rate limit of 3 tries in one minute the scale_ms value is set to 60,000 milliseconds for one minute. limit - the number of attempts allowed with the scale_ms duration. In the example of 3 tries in one minute, the limit value is 3. Example iex&gt; MsbmsSystRateLimiter . check_rate_with_increment ( ...&gt; :check_with_increment , ...&gt; &quot;id1&quot; , ...&gt; 60_000 , ...&gt; 10 , ...&gt; 7 ) { :allow , 7 } iex&gt; MsbmsSystRateLimiter . check_rate_with_increment ( ...&gt; :check_with_increment , ...&gt; &quot;id1&quot; , ...&gt; 60_000 , ...&gt; 10 , ...&gt; 2 ) { :allow , 9 } iex&gt; MsbmsSystRateLimiter . check_rate ( :check_with_increment , &quot;id1&quot; , 60_000 , 10 ) { :allow , 10 }","ref":"MsbmsSystRateLimiter.html#check_rate_with_increment/5","title":"MsbmsSystRateLimiter.check_rate_with_increment/5","type":"function"},{"doc":"Deletes a counter from the system. Parameters counter_type - an atom representing the kind of counter which is to be deleted. counter_id - the specific Counter ID of the type. For example if the counter_type is :user_login , the counter_id value may be a value like user@email.domain for the user's username. Example iex&gt; MsbmsSystRateLimiter . check_rate ( :delete_test_counter , &quot;id1&quot; , 60_000 , 3 ) { :allow , 1 } iex&gt; MsbmsSystRateLimiter . delete_counters ( :delete_test_counter , &quot;id1&quot; ) { :ok , 1 }","ref":"MsbmsSystRateLimiter.html#delete_counters/2","title":"MsbmsSystRateLimiter.delete_counters/2","type":"function"},{"doc":"Returns an anonymous function to simplify calls to check the rate for a specific counter type. The returned function avoids requiring the parameters that are common between calls from being constantly supplied. The only parameter that the returned function requires is the counter_id value of the specific counter of the type to test; all other parameters typically required by MsbmsSystRateLimiter.check_rate/4 are captured by the returned closure. Parameters counter_type - an atom representing the kind of counter that the returned function will be set to check. scale_ms - the time in milliseconds of the rate window. For example, for the rate limit of 3 tries in one minute the scale_ms value is set to 60,000 milliseconds for one minute. limit - the number of attempts allowed with the scale_ms duration. In the example of 3 tries in one minute, the limit value is 3. Example Note that The returned anonymous function is equivalent to making a call to the more verbose MsbmsSystRateLimiter.check_rate/4 : iex&gt; my_check_rate_function = ...&gt; MsbmsSystRateLimiter . get_check_rate_function ( ...&gt; :example_counter_get_func , ...&gt; 60_000 , ...&gt; 3 ) iex&gt; my_check_rate_function . ( &quot;id1&quot; ) { :allow , 1 } iex&gt; MsbmsSystRateLimiter . check_rate ( ...&gt; :example_counter_get_func , ...&gt; &quot;id1&quot; , ...&gt; 60_000 , ...&gt; 3 ) { :allow , 2 } iex&gt; my_check_rate_function . ( &quot;id1&quot; ) { :allow , 3 }","ref":"MsbmsSystRateLimiter.html#get_check_rate_function/3","title":"MsbmsSystRateLimiter.get_check_rate_function/3","type":"function"},{"doc":"Creates a canonical name for each unique counter. Parameters counter_type - an atom representing the kind of counter being created. counter_id - a value unique to the counter_type which identifies a specific counter. Example iex&gt; MsbmsSystRateLimiter . get_counter_name ( :example_counter_name , &quot;123&quot; ) &quot;example_counter_name_123&quot;","ref":"MsbmsSystRateLimiter.html#get_counter_name/2","title":"MsbmsSystRateLimiter.get_counter_name/2","type":"function"},{"doc":"Initializes the rate limiter table. This function must be called per the instructions of MsbmsSystRateLimiter prior to the checking the rate of any counter. Parameters opts - a keyword list of optional parameters. Valid options are: mnesia_table_args - a list of options to be passed directly to :mnesia.create_table/2 . For complete documentation of the available Mnesia table options see the Erlang documentation .","ref":"MsbmsSystRateLimiter.html#init_rate_limiter/1","title":"MsbmsSystRateLimiter.init_rate_limiter/1","type":"function"},{"doc":"Retrieves data about a currently used counter without counting towards the limit. Parameters counter_type - an atom representing the kind of counter which to inspect. counter_id - the specific Counter ID of the type. For example if the counter_type is :user_login , the counter_id value may be a value like user@email.domain for the user's username. scale_ms - the time in milliseconds of the rate window. For example, for the rate limit of 3 tries in one minute the scale_ms value is set to 60,000 milliseconds for one minute. limit - the number of attempts allowed with the scale_ms duration. In the example of 3 tries in one minute, the limit value is 3.","ref":"MsbmsSystRateLimiter.html#inspect_counter/4","title":"MsbmsSystRateLimiter.inspect_counter/4","type":"function"},{"doc":"Defines public types for use with the MsbmsSystRateLimiter module.","ref":"MsbmsSystRateLimiter.Types.html","title":"MsbmsSystRateLimiter.Types","type":"module"},{"doc":"A unique identifier for the specific counter within the requested counter type.","ref":"MsbmsSystRateLimiter.Types.html#t:counter_id/0","title":"MsbmsSystRateLimiter.Types.counter_id/0","type":"type"},{"doc":"The name of the counter which is derived from the counter type and counter id values.","ref":"MsbmsSystRateLimiter.Types.html#t:counter_name/0","title":"MsbmsSystRateLimiter.Types.counter_name/0","type":"type"},{"doc":"The type of value expected for the table which holds the counters.","ref":"MsbmsSystRateLimiter.Types.html#t:counter_table_name/0","title":"MsbmsSystRateLimiter.Types.counter_table_name/0","type":"type"},{"doc":"The kind of activity being rate limited. For example, a counter type might be :login_attempt .","ref":"MsbmsSystRateLimiter.Types.html#t:counter_type/0","title":"MsbmsSystRateLimiter.Types.counter_type/0","type":"type"}]