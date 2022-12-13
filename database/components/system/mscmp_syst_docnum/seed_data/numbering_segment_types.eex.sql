-- File:        numbering_segment_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/seed_data/numbering_segment_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

INSERT INTO ms_syst_data.syst_numbering_segment_types
    ( internal_name, display_name, syst_description )
VALUES
    ( 'enumeration'
    , 'List of Values'
    , 'References a configured enumeration which provides choices from which the segment values are drawn.' )
     ,
    ( 'sequence'
    , 'Sequential Number'
    , 'A sequential numbering.  Supports increment/decrement, skip sequencing, and gap-less sequencing.' )
     ,
    ( 'fixed_text'
    , 'Fixed Text'
    , 'A fixed text segment which can be used to define separators, prefixes, suffixes, or other static elements.' )
     ,
    ( 'free_text'
    , 'Free Text'
    , 'Allows users to enter arbitrary text, subject to a pattern matched validation.' )
     ,
    ( 'random', 'Random Number', 'Generates random numbers.' )
     ,
    ( 'sequence_in_prior'
    , 'Sequence In Prior'
    , 'Returns an incrementing sequential number within a grouping defined by the prior segments.' );
