package bootstrap

import (
	"context"

	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
)

type Application struct {
	Env   *Env
	Mongo mongo.Client
}

func InitApp() (*Application, error) {
	env, err := NewEnv()
	if err != nil {
		return nil, err
	}

	mongoClient, err := mongo.NewClient(env.DB_Uri)
	if err != nil {
		return nil, err
	}

	return &Application{
		Env:   env,
		Mongo: mongoClient,
	}, nil
}

func (app *Application) CloseDBConnection() {
	if app.Mongo != nil {
		_ = app.Mongo.Disconnect(context.TODO())
	}
}
