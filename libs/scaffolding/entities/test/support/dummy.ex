defmodule Noizu.Support.Entity.ETS.DummyRepo do
  @moduledoc false
end

defmodule Noizu.Support.Entity.ETS.DummyRecord do
  @moduledoc false
  defstruct id: nil,
            name: nil,
            title: nil,
            title2: nil,
            description: nil,
            json_template_specific: nil,
            json_template_specific2: nil,
            time_stamp: nil,
            special_field_id: nil,
            special_field_sno: nil,
            reference_field_ref: nil,
            reference_field_ref_type: nil
end
