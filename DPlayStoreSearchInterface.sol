pragma solidity ^0.5.9;

interface DPlayStoreSearchInterface {
	
	// 태그 정보
	struct GameTags {
		string tag1;
		string tag2;
		string tag3;
		string tag4;
	}
	
	// 언어별로 게임의 태그를 입력합니다.
	function setGameDetails(
		uint gameId,
		string calldata language,
		string calldata tag1,
		string calldata tag2,
		string calldata tag3,
		string calldata tag4) external;
	
	// 출시된 게임 ID들을 가져옵니다.
	function getPublishedGameIds() external view returns (uint[] memory);
	
	// 게임 ID들을 최신 순으로 가져옵니다.
	function getGameIdsNewest() external view returns (uint[] memory);
	
	// 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	function getGameIdsByRating(uint ratingCount) external view returns (uint[] memory);
	
	// 태그에 해당하는 게임 ID들을 최신 순으로 가져옵니다.
	function getGameIdsByTagNewest(string calldata language, string calldata tag) external view returns (uint[] memory);
	
	// 태그에 해당하는 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	function getGameIdsByTagAndRating(string calldata language, string calldata tag, uint ratingCount) external view returns (uint[] memory);
}