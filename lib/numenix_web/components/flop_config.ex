defmodule NumenixWeb.FlopConfig do
  def pagination_opts do
    [
      page_links: {:ellipsis, 5},
      disabled_class: "disabled opacity-50",
      wrapper_attrs: [
        class: "text-center mt-4 flex"
      ],
      previous_link_content: Phoenix.HTML.raw(Gettext.gettext(NumenixWeb.Gettext, "< Previous")),
      previous_link_attrs: [
        class:
          "rounded-md text-sm font-medium focus-visible:ring-ring focus-visible:outline-none focus-visible:ring-1 disabled:pointer-events-none disabled:opacity-50 h-9 px-4 py-2 hover:bg-accent hover:text-accent-foreground gap-1 pr-2.5"
      ],
      pagination_list_attrs: [
        class: "flex order-2 place-items-center gap-4 px-4"
      ],
      current_link_attrs: [
        class:
          "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:ring-ring focus-visible:outline-none focus-visible:ring-1 disabled:pointer-events-none disabled:opacity-50 h-9 w-9 border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground"
      ],
      next_link_content: Phoenix.HTML.raw(Gettext.gettext(NumenixWeb.Gettext, "Next >")),
      next_link_attrs: [
        class:
          "order-3 rounded-md text-sm font-medium transition-colors focus-visible:ring-ring focus-visible:outline-none focus-visible:ring-1 disabled:pointer-events-none disabled:opacity-50 h-9 px-4 py-2 hover:bg-accent hover:text-accent-foreground gap-1 pr-2.5"
      ]
    ]
  end

  def table_opts do
    [
      table_attrs: [class: "table table-sm table-zebra"],
      tbody_td_attrs: [class: "cursor-pointer"]
    ]
  end
end
