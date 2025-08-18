# typst-json-curriculum-vitae

This package uses fontawesome, you should install the font first.

## Usage

```typ
#import "@preview/json-curriculum-vitae:0.0.1": show_cv

#let path_json = sys.inputs.at("CV_JSON", default: "cv_data.json")
#let data = json(path_json)
#show_cv(data)
```

## Compilation

```sh
typst compile cv.typ --input CV_LANG=en CV_en.pdf
typst compile cv.typ --input CV_LANG=fr CV_fr.pdf
```

## Lisence

- [MIT](./LICENSE)
