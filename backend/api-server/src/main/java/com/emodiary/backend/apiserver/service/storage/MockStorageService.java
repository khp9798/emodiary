package com.emodiary.backend.apiserver.service.storage;

import java.time.LocalDate;
import java.util.UUID;

import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

import com.emodiary.backend.apiserver.dto.files.PresignResponse;

@Service
@Profile({"local","dev","default"}) // S3 구현 들어오면 prod로 스위칭 예정
public class MockStorageService implements StorageService {

	@Override
	public PresignResponse createPresignedUploadUrl(String fileName, String mimeType) {

		//만료 시간
		long expires = 600L;

		// 날짜 디렉터리 + uuid로 key 구성
		String date = LocalDate.now().toString(); //yyyy-mm-dd 형식
		String ext = fileName != null && fileName.contains(".") ? fileName.substring(fileName.lastIndexOf(".")) : ".m4a";
		String key = "uploads/voice"+date+"/"+ UUID.randomUUID()+ext;

		//Mock 업로드 URL (Put으로 업로드한다고 가정)
		String uploadUrl = "https://mock-s3.local/object/" + key + "?signature=mock&expires=" + expires;

		return new PresignResponse(uploadUrl, key, expires);
	}
}
