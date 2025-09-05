package email

import (
	"context"
	"fmt"

	gomail "gopkg.in/mail.v2"
)

type GomailEmailService struct {
	dialer *gomail.Dialer
	from   string
}

func NewGomailEmailService(smtpHost string, smtpPort int, from, username, password string) *GomailEmailService {
	dialer := gomail.NewDialer(smtpHost, smtpPort, username, password)
	return &GomailEmailService{
		dialer: dialer,
		from:   from,
	}
}

func (s *GomailEmailService) SendEmail(ctx context.Context, to, subject, body string) error {
	m := gomail.NewMessage()
	m.SetHeader("From", m.FormatAddress(s.from, "No-Reply"))
	m.SetHeader("To", m.FormatAddress(to, "Recipient"))
	m.SetHeader("Subject", subject)
	m.SetBody("text/html", body)
    fmt.Println("Sending email to:", to, "From:", s.from) // For debugging; remove in production
	return s.dialer.DialAndSend(m)
}
