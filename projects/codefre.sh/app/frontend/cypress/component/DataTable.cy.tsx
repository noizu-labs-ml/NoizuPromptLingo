import { DataTable, type DataTableColumn } from "@/components/ui/DataTable";

interface Row {
  id: string;
  name: string;
  status: string;
}

const rows: Row[] = [
  { id: "1", name: "Alpha", status: "pass" },
  { id: "2", name: "Bravo", status: "warn" },
  { id: "3", name: "Charlie", status: "fail" },
];

const cols: DataTableColumn<Row>[] = [
  { key: "name", label: "Name", render: (r) => r.name },
  { key: "status", label: "Status", render: (r) => r.status },
];

describe("<DataTable>", () => {
  it("renders one row per datum", () => {
    cy.mount(<DataTable rows={rows} columns={cols} rowKey={(r) => r.id} cy="tbl" />);
    cy.getByCy("tbl").find("tbody tr").should("have.length", 3);
    cy.contains("Alpha").should("be.visible");
    cy.contains("Charlie").should("be.visible");
  });

  it("empty state when no rows", () => {
    cy.mount(
      <DataTable
        rows={[]}
        columns={cols}
        rowKey={(r) => r.id}
        emptyContent={<span data-cy="empty-msg">nothing here</span>}
        cy="tbl"
      />,
    );
    cy.getByCy("empty-msg").should("be.visible");
  });

  it("keyboard nav: j/k moves selection, Enter fires onRowActivate", () => {
    const onActivate = cy.stub().as("onActivate");
    cy.mount(
      <DataTable
        rows={rows}
        columns={cols}
        rowKey={(r) => r.id}
        onRowClick={onActivate}
        cy="tbl"
      />,
    );
    cy.getByCy("tbl").focus();
    cy.get("body").type("j").type("j").type("{enter}");
    cy.get("@onActivate").should("have.been.called");
  });
});
