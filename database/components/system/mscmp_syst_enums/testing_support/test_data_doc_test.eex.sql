-- File:        test_data_doc_test.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/testing_support/test_data_doc_test.eex.sql
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
    ( 'example_enumeration'
    , 'Example Enumeration'
    , 'A enumeration to use in examples and doctests.'
    , FALSE
    , TRUE
    , jsonb_build_object( 'enum_option_one', 1, 'enum_option_two', 2, 'enum_option_three',
                          ARRAY ['array_value1', 'array_value2', 'array_value3']::text[] ) );

-- Enum Functional Types

INSERT INTO ms_syst_data.syst_enum_functional_types
    ( internal_name, display_name, external_name, enum_id, syst_description )
VALUES
    ( 'example_enum_func_type_1'
    , 'Example/Functional Type 1'
    , 'Example Type 1'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'example_enumeration' )
    , 'Example Functional Type One' )
     ,
    ( 'example_enum_func_type_2'
    , 'Example/Functional Type 2'
    , 'Example Type 2'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'example_enumeration' )
    , 'Example Functional Type Two' );

--  Enum Values: Example Enumeration

INSERT INTO ms_syst_data.syst_enum_items
    ( internal_name
    , display_name
    , external_name
    , enum_id
    , functional_type_id
    , enum_default
    , syst_defined
    , user_maintainable
    , syst_description
    , sort_order )
VALUES
    ( 'example_enum_item_two'
    , 'Example / Two'
    , 'Example Two'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'example_enumeration' )
    , ( SELECT id
        FROM ms_syst_data.syst_enum_functional_types
        WHERE internal_name = 'example_enum_func_type_1' )
    , TRUE
    , TRUE
    , TRUE
    , 'Example list item two, should sort into second place.'
    , 1 );

INSERT INTO ms_syst_data.syst_enum_items
    ( internal_name
    , display_name
    , external_name
    , enum_id
    , functional_type_id
    , enum_default
    , syst_defined
    , user_maintainable
    , syst_description )
VALUES
    ( 'example_enum_item_three'
    , 'Example / Three'
    , 'Example Three'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'example_enumeration' )
    , ( SELECT id
        FROM ms_syst_data.syst_enum_functional_types
        WHERE internal_name = 'example_enum_func_type_2' )
    , FALSE
    , TRUE
    , FALSE
    , 'Example list item three, should sort into third place.' );

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
    ( 'example_enum_item_one'
    , 'Example / One'
    , 'Example One'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'example_enumeration' )
    , ( SELECT id
        FROM ms_syst_data.syst_enum_functional_types
        WHERE internal_name = 'example_enum_func_type_1' )
    , FALSE
    , TRUE
    , TRUE
    , FALSE
    , 'Example list item one, should sort into first place.'
    , 1 );
