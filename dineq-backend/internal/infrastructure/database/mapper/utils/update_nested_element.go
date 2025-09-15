package utils

import "go.mongodb.org/mongo-driver/v2/bson"

// Example: path = "menu.items.$."
func BuildNestedUpdate(path string, fields map[string]any) bson.M {
	result := bson.M{}
	for key, value := range fields {
		result[path+key] = value
	}
	return bson.M{"$set": result}
}
