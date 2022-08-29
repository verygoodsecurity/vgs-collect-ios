//
//  RequestResult.swift
//  demoapp

import Foundation

enum RequestResult<T> {
	case success(T)
	case error(String?)
	case isLoading
}
