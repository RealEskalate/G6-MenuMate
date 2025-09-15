package utils

import (
	"bytes"
	"embed"
	"html/template"
)

//go:embed template/*.html

var templatesFS embed.FS

func RenderTemplate(name string, data any) (string, error) {
	tmpl, err := template.ParseFS(templatesFS, "template/"+name)
	if err != nil {
		return "", err
	}

	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, data); err != nil {
		return "", err
	}
	return buf.String(), nil
}
