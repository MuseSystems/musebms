-- File:        test_data_unit_test.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/testing_support/test_data_unit_test.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

--------------------------------------------------------------------------------
--  Primary Initialization -- Enumerations
--------------------------------------------------------------------------------

INSERT INTO ms_syst_data.syst_enums
    ( internal_name
    , display_name
    , syst_description
    , syst_defined
    , user_maintainable
    , default_syst_options )
VALUES
    ( 'test_syst_enum_one'
    , 'Test System Enum One'
    , 'A test of a system enumeration (one).'
    , TRUE
    , FALSE
    , jsonb_build_object( 'key_one', 1, 'key_two', 2, 'key_three',
                          ARRAY ['test1', 'test2', 'test3']::text[] ) )
     ,
    ( 'test_syst_enum_two'
    , 'Test System Enum Two'
    , 'A test of a system enumeration (two).'
    , TRUE
    , TRUE
    , jsonb_build_object( 'key_one', 1, 'key_two', 2, 'key_three',
                          ARRAY ['test1', 'test2', 'test3']::text[] ) )
     ,
    ( 'test_syst_enum_three'
    , 'Test System Enum Three'
    , 'A test of a system enumeration (three).'
    , TRUE
    , TRUE
    , jsonb_build_object( 'key_one', 1, 'key_two', 2, 'key_three',
                          ARRAY ['test1', 'test2', 'test3']::text[] ) );

-- Enum Functional Types

INSERT INTO ms_syst_data.syst_enum_functional_types
    ( internal_name, display_name, external_name, enum_id, syst_description )
VALUES
    ( 'enum_one_active'
    , 'Enum One/Active'
    , 'Active'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'test_syst_enum_one' )
    , 'Testing Enum One Functional Type Active' )
     ,
    ( 'enum_one_inactive'
    , 'Enum One/Inactive'
    , 'Inactive'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'test_syst_enum_one' )
    , 'Testing Enum One Functional Type Inactive' )
     ,
    ( 'enum_three_active'
    , 'Enum Three/Active'
    , 'Active'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'test_syst_enum_three' )
    , 'Testing Enum Three Functional Type Active' )
     ,
    ( 'enum_three_inactive'
    , 'Enum Three/Inactive'
    , 'Inactive'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'test_syst_enum_three' )
    , 'Testing Enum Three Functional Type Inactive' );

--  Enum Values: Enum One

INSERT INTO ms_syst_data.syst_enum_items
    ( internal_name
    , display_name
    , external_name
    , enum_id
    , functional_type_id
    , enum_default
    , functional_type_default
    , syst_defined
    , user_maintainable
    , syst_description
    , sort_order
    , syst_options )
VALUES
    ( 'enum_one_cancelled'
    , 'Enum One/Cancelled'
    , 'Cancelled'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'test_syst_enum_one' )
    , ( SELECT id
        FROM ms_syst_data.syst_enum_functional_types
        WHERE internal_name = 'enum_one_inactive' )
    , FALSE
    , FALSE
    , TRUE
    , TRUE
    , 'Enum One/Cancelled System Description'
    , 1
    , jsonb_build_object( 'cancel1', 1, 'cancel2', 'b', 'cancel3', TRUE ) );

INSERT INTO ms_syst_data.syst_enum_items
    ( internal_name
    , display_name
    , external_name
    , enum_id
    , functional_type_id
    , enum_default
    , functional_type_default
    , syst_defined
    , user_maintainable
    , syst_description
    , syst_options )
VALUES
    ( 'enum_one_closed'
    , 'Enum One/Closed'
    , 'Closed'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'test_syst_enum_one' )
    , ( SELECT id
        FROM ms_syst_data.syst_enum_functional_types
        WHERE internal_name = 'enum_one_inactive' )
    , FALSE
    , TRUE
    , TRUE
    , TRUE
    , 'Enum One/Closed System Description'
    , jsonb_build_object( 'closed1', 1, 'closed2', 'b', 'closed3', TRUE ) );

INSERT INTO ms_syst_data.syst_enum_items
    ( internal_name
    , display_name
    , external_name
    , enum_id
    , functional_type_id
    , enum_default
    , functional_type_default
    , syst_defined
    , user_maintainable
    , syst_description
    , sort_order
    , syst_options )
VALUES
    ( 'enum_one_active'
    , 'Enum One/Active'
    , 'Active'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'test_syst_enum_one' )
    , ( SELECT id
        FROM ms_syst_data.syst_enum_functional_types
        WHERE internal_name = 'enum_one_active' )
    , TRUE
    , TRUE
    , TRUE
    , FALSE
    , 'Enum One/Active System Description'
    , 1
    , jsonb_build_object( 'key1', 1, 'key2', 'b', 'key3', TRUE ) );

--  Enum Values: Enum Two

INSERT INTO ms_syst_data.syst_enum_items
    ( internal_name
    , display_name
    , external_name
    , enum_id
    , enum_default
    , syst_defined
    , user_maintainable
    , syst_description
    , sort_order )
VALUES
    ( 'enum_two_cancelled'
    , 'Enum Two/Cancelled'
    , 'Cancelled'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'test_syst_enum_two' )
    , FALSE
    , TRUE
    , TRUE
    , 'Enum Two/Cancelled System Description'
    , 1 );

INSERT INTO ms_syst_data.syst_enum_items
    ( internal_name
    , display_name
    , external_name
    , enum_id
    , enum_default
    , syst_defined
    , user_maintainable
    , syst_description )
VALUES
    ( 'enum_two_closed'
    , 'Enum Two/Closed'
    , 'Closed'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'test_syst_enum_two' )
    , FALSE
    , TRUE
    , FALSE
    , 'Enum Two/Closed System Description' );

INSERT INTO ms_syst_data.syst_enum_items
    ( internal_name
    , display_name
    , external_name
    , enum_id
    , enum_default
    , syst_defined
    , user_maintainable
    , syst_description
    , sort_order )
VALUES
    ( 'enum_two_active'
    , 'Enum Two/Active'
    , 'Active'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'test_syst_enum_two' )
    , TRUE
    , TRUE
    , FALSE
    , 'Enum Two/Active System Description'
    , 1 );

--  Enum Values: Enum Three

INSERT INTO ms_syst_data.syst_enum_items
    ( internal_name
    , display_name
    , external_name
    , enum_id
    , functional_type_id
    , enum_default
    , functional_type_default
    , syst_defined
    , user_maintainable
    , syst_description )
VALUES
    ( 'enum_three_closed'
    , 'Enum Three/Closed'
    , 'Closed'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'test_syst_enum_three' )
    , ( SELECT id
        FROM ms_syst_data.syst_enum_functional_types
        WHERE internal_name = 'enum_three_inactive' )
    , FALSE
    , TRUE
    , TRUE
    , TRUE
    , 'Enum Three/Closed System Description' );

INSERT INTO ms_syst_data.syst_enum_items
    ( internal_name
    , display_name
    , external_name
    , enum_id
    , functional_type_id
    , enum_default
    , functional_type_default
    , syst_defined
    , user_maintainable
    , syst_description
    , sort_order )
VALUES
    ( 'enum_three_active'
    , 'Enum Three/Active'
    , 'Active'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'test_syst_enum_three' )
    , ( SELECT id
        FROM ms_syst_data.syst_enum_functional_types
        WHERE internal_name = 'enum_three_active' )
    , TRUE
    , TRUE
    , TRUE
    , FALSE
    , 'Enum Three/Active System Description'
    , 1 );
