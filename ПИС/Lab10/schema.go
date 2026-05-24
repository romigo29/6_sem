package main

import (
	"errors"

	"github.com/graphql-go/graphql"
)

// Определение GraphQL типа для Celebrity
var celebrityType = graphql.NewObject(graphql.ObjectConfig{
	Name: "Celebrity",
	Fields: graphql.Fields{
		"id":           &graphql.Field{Type: graphql.Int},
		"fullName":     &graphql.Field{Type: graphql.String},
		"nationality":  &graphql.Field{Type: graphql.String},
		"reqPhotoPath": &graphql.Field{Type: graphql.String},
	},
})

// Корневые запросы (эквивалент GET /Celebrities/All и GET /Celebrities/{id})
var rootQuery = graphql.NewObject(graphql.ObjectConfig{
	Name: "RootQuery",
	Fields: graphql.Fields{
		"celebrities": &graphql.Field{
			Type: graphql.NewList(celebrityType),
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				var celebrities []Celebrity
				if err := db.Find(&celebrities).Error; err != nil {
					return nil, err
				}
				return celebrities, nil
			},
		},
		"celebrity": &graphql.Field{
			Type: celebrityType,
			Args: graphql.FieldConfigArgument{
				"id": &graphql.ArgumentConfig{Type: graphql.NewNonNull(graphql.Int)},
			},
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				id := p.Args["id"].(int)
				var c Celebrity
				if err := db.First(&c, id).Error; err != nil {
					return nil, errors.New("Not found")
				}
				return c, nil
			},
		},
	},
})

// Корневые мутации (эквивалент POST, PUT и DELETE)
var rootMutation = graphql.NewObject(graphql.ObjectConfig{
	Name: "RootMutation",
	Fields: graphql.Fields{
		"createCelebrity": &graphql.Field{
			Type: celebrityType,
			Args: graphql.FieldConfigArgument{
				"fullName":     &graphql.ArgumentConfig{Type: graphql.NewNonNull(graphql.String)},
				"nationality":  &graphql.ArgumentConfig{Type: graphql.NewNonNull(graphql.String)},
				"reqPhotoPath": &graphql.ArgumentConfig{Type: graphql.NewNonNull(graphql.String)},
			},
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				c := Celebrity{
					FullName:     p.Args["fullName"].(string),
					Nationality:  p.Args["nationality"].(string),
					ReqPhotoPath: p.Args["reqPhotoPath"].(string),
				}
				if err := db.Create(&c).Error; err != nil {
					return nil, err
				}
				return c, nil
			},
		},
		"updateCelebrity": &graphql.Field{
			Type: celebrityType,
			Args: graphql.FieldConfigArgument{
				"id":           &graphql.ArgumentConfig{Type: graphql.NewNonNull(graphql.Int)},
				"fullName":     &graphql.ArgumentConfig{Type: graphql.String},
				"nationality":  &graphql.ArgumentConfig{Type: graphql.String},
				"reqPhotoPath": &graphql.ArgumentConfig{Type: graphql.String},
			},
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				id := p.Args["id"].(int)
				var c Celebrity

				if err := db.First(&c, id).Error; err != nil {
					return nil, errors.New("Not found")
				}

				if fullName, ok := p.Args["fullName"].(string); ok {
					c.FullName = fullName
				}
				if nationality, ok := p.Args["nationality"].(string); ok {
					c.Nationality = nationality
				}
				if reqPhotoPath, ok := p.Args["reqPhotoPath"].(string); ok {
					c.ReqPhotoPath = reqPhotoPath
				}

				db.Save(&c)
				return c, nil
			},
		},
		"deleteCelebrity": &graphql.Field{
			Type: graphql.Boolean,
			Args: graphql.FieldConfigArgument{
				"id": &graphql.ArgumentConfig{Type: graphql.NewNonNull(graphql.Int)},
			},
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				id := p.Args["id"].(int)
				result := db.Delete(&Celebrity{}, id)

				if result.RowsAffected == 0 {
					return false, errors.New("Not found")
				}
				return true, nil
			},
		},
	},
})

// Инициализация схемы GraphQL
var Schema, _ = graphql.NewSchema(graphql.SchemaConfig{
	Query:    rootQuery,
	Mutation: rootMutation,
})