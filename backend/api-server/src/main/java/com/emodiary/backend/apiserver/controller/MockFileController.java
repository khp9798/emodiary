package com.emodiary.backend.apiserver.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/files")
public class MockFileController {

	@GetMapping("/mock-upload")
	public ResponseEntity<String> mockUpload(){
		return ResponseEntity.ok("mock upload");
	}
}
