# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2025 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.Entity.Meta.ACL do
  @moduledoc """
  Meta Data Record for ACL settings.
  """

  require Record

  Record.defrecord(:acl_settings, target: nil, type: nil, requirement: nil)

  @typedoc """
  Target/Field acl restriction applies to.
  """
  @type acl_target :: term

  @typedoc """
  ACL type
  """
  @type acl_type :: term

  @typedoc """
  ACL requirement
  """
  @type acl_requirement :: term

  @typedoc """
  ACL Metadata entry
  """
  @type acl_settings ::
          record(:acl_settings,
            target: acl_target,
            type: acl_type,
            requirement: acl_requirement
          )
end
