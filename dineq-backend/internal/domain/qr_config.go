package domain

type QRConfig struct {
	Format    string
	Size      int
	Start     string  // gradient start
	End       string  // gradient end
	LogoURL   string  // remote image URL, leave empty to use LogoPath
	LogoScale float64 // fraction of QR size, 0.0 uses 0.20
	WhiteBg   bool    // draw white rectangle behind logo
}
