//
//  QuerySuggestionHelper.swift
//  Debugger
//
//  Created by Godwin Joseph on 24/06/19.
//  Copyright © 2019 Godwin Joseph. All rights reserved.
//

import Cocoa

class QuerySuggestionHelper: NSObject {

    private static func getBasicQueries() -> [String]{
        return  [
            //basic command
            "SELECT ",
            "SELECT * ",
            "UPDATE ",
            "DELETE ",
            "INSERT INTO ",
            "CREATE DATABASE ",
            "CREATE TABLE ",
            "ALTER TABLE ",
            "DROP TABLE ",
            "DROP DATABASE ",
            "CREATE INDEX ",
            "DROP INDEX ",
            //support
            "FROM ",
            "WHERE ",
            "SELECT DISTINCT ",
            "DISTINCT ",
            "SELECT COUNT() ",
            "COUNT() ",
            "AS ",
            "AND ",
            "OR ",
            "NOT ",
            "ORDER BY ",
            "ASC ",
            "DESC ",
            "VALUES ",
            "IS ",
            "NULL ",
            "NOT NULL ",
            "SET ",
            "LIMIT ",
            "OFFSET ",
            "SELECT MIN() ",
            "MIN() ",
            "SELECT MAX() ",
            "MAX() ",
            "AVG() ",
            "SUM() ",
            "LIKE ",
            "IN ",
            "BETWEEN ",
            "NOT BETWEEN ",
            "JOIN ",
            "INNER JOIN ",
            "LEFT JOIN ",
            "RIGHT JOIN ",
            "FULL JOIN ",
            "ON ",
            "UNION ",
            "UNION ALL ",
            "GROUP BY ",
            "HAVING ",
            "EXISTS ",
            "ANY ",
            "ALL ",
            "INTO ",
            "UNIQUE ",
            "PRIMARY KEY ",
            "FOREIGN KEY ",
            "CHECK ",
            "DEFAULT "]
    }
    public static func getBasicQueryCommands() -> [String]{
        return getBasicQueries()
    }

    public static func getDbTokens(database: DDatabase) -> [String]{
        var arr = getBasicQueries()

        for table in database.tables{
            arr.append(table.name)
            for column in table.columnNames {
                arr.append(column)
            }
        }
        return arr
    }
}
