#import "../porygon.typ": show-cv


#let path_json = sys.inputs.at("CV_JSON", default: "cv_data.json")
#let data = json(path_json)
#show-cv(data)

