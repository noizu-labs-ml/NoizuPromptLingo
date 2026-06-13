ExUnit.configure(formatters: [JUnitFormatter, ExUnit.CLIFormatter])

Mimic.copy(Noizu.Entity.Store.Dummy.StorageLayer)
Amnesia.start()
NoizuEntityTestDb.create()
NoizuEntityTestDb.BizBops.BizBopTable.create(disk: [node()])
ExUnit.start()
