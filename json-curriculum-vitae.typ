#import "@preview/fontawesome:0.6.0": fa-icon

#let document_lang = state("document_lang", "en")

#let translate(val) = {
  if type(val) == dictionary {
    let is_val = val.at(document_lang.get(), default: none)
    if is_val != none {
      str(val.at(document_lang.get()))
    }
  } else {
    str(val)
  }
}

#let render_text(val) = {
  let val = translate(val)
  let render_text_str(val) = {
    let parse_url(value) = {
      let regex_full_url = regex("(.*)\\\href\{([^\{]*?)\}\{(.*)\}(.*)")
      let matched = value.match(regex_full_url)
      if matched == none {
        return value
      }
      let captures = matched.captures
      let before = captures.at(0)
      let url = captures.at(1)
      let (url_link, after) = (captures.at(2), captures.at(3))
      let url_link = render_text_str(url_link)
      return before + "#link(\"" + url + "\")[" + url_link + "]" + after
    }
    let parse_textbf(val) = {
      let regex_bf = regex("(.*)\\\\textbf\{([^\{]*?)\}(.*)")
      let mat = val.match(regex_bf)
      if mat == none {
        return val
      }
      return mat.captures.at(0) + " *" + mat.captures.at(1) + "* " + mat.captures.at(2)
    }
    let remove_new_line(val_li) = {
      return val_li.replace("\\newline", " #linebreak() ")
    }
    let text = remove_new_line(val)
    let text = parse_url(text)
    let text = parse_textbf(text)
    return text
  }
  let final_text = render_text_str(val)
  eval(final_text, mode: "markup")
}

#let show_title(title) = {
  let value = translate(title)
  grid(
    columns: (auto, 1fr),
    align: (auto, horizon),
    gutter: 5pt,
    heading(value), align(horizon, line(length: 100%)),
  )
}

#let show_title_bar(title) = {
  let value = translate(title)
  stack(
    dir: ttb,
    [ == #value ],
    v(0.5em),
    line(length: 95%),
  )
}

#let filter_by_lang(data_list, field) = {
  let filter_lang(one_e) = {
    if type(one_e.at(field)) == str {
      return true
    } else if one_e.at("optional", default: none) == true {
      return false
    } else if one_e.at(field).keys().contains(document_lang.get()) {
      return true
    }
    return false
  }
  data_list.filter(filter_lang)
}

#let show_contact(data) = {
  align(center, [
    #set text(15pt)
    *#data.firstname #data.lastname*
    #linebreak()
  ])
  if document_lang.get() == "en" {
    align(center, translate(data.bio))
  } else {
    align(center, [
      #circle(height: 4.5cm, inset: -18pt, outset: 0pt)[
        #set align(center + horizon)
        #block(
          clip: true,
          radius: 50%,
          image(data.picture, height: 6cm),
        )
      ]
    ])
  }
  show_title_bar(data.sidebar)
  let spacing = 0.4em
  align(right, stack(
    link("mailto:" + data.mail)[#data.mail],
    v(spacing),
    [
      #translate(data.location)
      #fa-icon("location-dot")
    ],
    v(spacing),
    link("tel:" + data.phone)[#data.phone #fa-icon("phone")],
    v(spacing),
    [
      #translate(data.driving)
      #fa-icon("wpforms")
    ],
    v(spacing),
    link(data.website)[#data.website #fa-icon("home")],
    v(spacing),
    link(data.linkedin.link)[#data.linkedin.name #fa-icon("linkedin")],
    v(spacing),
    link(data.github.link)[#data.github.name #fa-icon("github")],
  ))
}

#let show_work((title, data)) = {
  show_title(title)
  let render_element((date, description, name)) = {
    let name = render_text(name)
    (
      align(top, translate(date)),
      block([#underline(name)#linebreak() #render_text(description)#v(0.5em)]),
    )
  }
  let content = filter_by_lang(data, "date").map(render_element).flatten()
  let rows = filter_by_lang(data, "date").map(e => auto)
  grid(
    columns: (0.20fr, 0.8fr),
    rows: rows,
    column-gutter: 10pt,
    row-gutter: 3pt,
    align: (x, _) => if x == 0 { right } else { left },
    ..content,
  )
}

#let show_personal((title, data), (list_ident,)) = {
  show_title(title)
  let content = filter_by_lang(data, "description").map(e => {
    render_text(e.description)
  })
  list(
    marker: [--],
    indent: list_ident,
    ..content,
  )
}

#let show_irl_langs((title, data), (row_gutter,)) = {
  show_title_bar(title)
  let content = data
    .map(e => {
      (
        block(strong(translate(e.name))),
        block([
          #set text(10pt)
          #render_text(e.level)
        ]),
      )
    })
    .flatten()
  let rows = data.map(e => auto)
  grid(
    columns: (0.5fr, 0.5fr),
    rows: rows,
    align: (x, _) => if x == 0 { right } else { left },
    row-gutter: row_gutter,
    column-gutter: 10pt,
    ..content,
  )
}

#let show_project((title, data), (list_ident,)) = {
  show_title(title)
  let content = filter_by_lang(data, "description").map(e => {
    render_text(e.description)
  })
  list(
    marker: [--],
    indent: list_ident,
    ..content,
  )
}

#let show_languages((title, data), (row_gutter)) = {
  show_title_bar(title)
  let content = data.map(e => [
    #e.name
  ])
  let rows = data.map(e => auto)
  grid(
    columns: (0.5fr, 0.5fr),
    align: (x, _) => if x == 0 { right } else { left },
    row-gutter: row_gutter,
    column-gutter: 10pt,
    ..content,
  )
}


#let show_tools((title, data), (row_gutter)) = {
  show_title_bar(title)
  let content = data.map(e => [
    #e.name
  ])
  let rows = data.map(e => auto)
  grid(
    columns: (0.5fr, 0.5fr),
    align: (x, _) => if x == 0 { right } else { left },
    row-gutter: row_gutter,
    column-gutter: 10pt,
    inset: 0pt,
    ..content,
  )
}

#let show_school((title, data)) = {
  show_title(title)
  for (date, name, location, description) in data [
  ]
  let data = filter_by_lang(data, "date")
  let nb_item = data.len()
  let render_element((idx, (date, name, location, description))) = {
    (
      align(top, translate(date)),
      stack(
        dir: ttb,
        strong(render_text(name)),
        v(0.2em),
        [#fa-icon("location-dot")#h(0.2em)#translate(location)],
        v(0.7em),
        render_text(
          description,
        ),
        if idx != (nb_item - 1) { v(0.5em) },
      ),
    )
  }
  let content = data.enumerate().map(render_element).flatten()
  let rows = filter_by_lang(data, "date").map(e => auto)
  grid(
    columns: (0.20fr, 0.80fr),
    rows: rows,
    column-gutter: 10pt,
    row-gutter: 3pt,
    align: (x, _) => if x == 0 { right } else { left },
    ..content,
  )
}

#let interest(hobby) = {
  let (ico, name) = hobby
  let ico = lower(ico.slice(3))
  let label = translate(name)
  align(center)[
    #stack(
      dir: ttb,
      circle(radius: 0.5cm, fill: rgb("4a90d9"))[
        #set align(center + horizon)
        #text(size: 1em, fill: white)[#fa-icon(ico)]
      ],
      v(0.4em),
      align(center, [#text(size: 0.7em)[#label]]),
    )
  ]
}

#let show_hobbies((title, data)) = {
  show_title_bar(title)
  block(
    width: 100%,
    [
      #grid(
        columns: (1fr, 1fr),
        align: horizon,
        interest(data.at(0)), interest(data.at(1)),
      )
      #align(center)[
        #interest(data.at(2))
      ]
    ],
  )
}


#let show_page_title(data) = {
  align(
    center,
    stack(
      dir: ttb,
      block[
        #set text(15pt)
        = #translate(data.title)
      ],
      v(0.8em),
      translate(data.subtitle),
    ),
  )
}


#let show_cv(json_path, lang: "en") = {
  let doc_lang = sys.inputs.at("CV_LANG", default: lang)
  document_lang.update(x => doc_lang)

  set document(
    title: "CV - " + data.me.firstname + " " + data.me.lastname,
    author: data.me.firstname
      + " "
      + data.me.lastname
      + " (created with https://github.com/Its-Just-Nans/curriculum-vitae)",
    description: "Curriculum Vitae of " + data.me.firstname + " " + data.me.lastname,
    keywords: data.me.keywords,
    date: datetime.today(),
  )


  set text(
    font: "Chivo",
  )

  let list_ident = 20pt
  let row_gutter = 8pt
  let white_smoke = rgb("#f5f5f5")
  let light_gray = rgb("#d3d3d3")

  set page(margin: (
    top: eval(data.margin.top),
    bottom: eval(data.margin.bottom),
    right: 0.8cm,
    left: 0.8cm,
  ))

  set par(
    leading: 0.55em,
  )


  grid(
    columns: (0.27fr, 4pt, 0.6fr),
    rows: 100%,
    column-gutter: 5pt,
    context {
      set text(
        size: 12pt,
      )
      align(horizon, [
        #show_contact(data.me)
        #show_languages(data.languages, (row_gutter,))
        #show_tools(data.tools, (row_gutter,))
        #show_irl_langs(data.langs, (row_gutter,))
        #show_hobbies(data.hobbies)
      ])
    },
    align(center + horizon, [
      #line(end: (00%, 90%), stroke: 4pt + white_smoke)
    ]),
    context {
      set text(
        size: 10pt,
      )
      align(horizon, [
        #show_page_title(data.me)
        #show_school(data.school)
        #show_work(data.work)
        #show_project(data.project, (row_gutter,))
        #show_personal(data.personal, (list_ident,))
      ])
    },
  )
}