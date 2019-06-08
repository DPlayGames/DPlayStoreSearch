pragma solidity ^0.5.9;

interface DPlayStoreSearchInterface {
	
	// 키워드 정보
	struct GameKeywords {
		string keyword1;
		string keyword2;
		string keyword3;
		string keyword4;
	}
	
	// 언어별로 게임의 키워드를 입력합니다.
	function setGameDetails(
		uint gameId,
		string calldata language,
		string calldata keyword1,
		string calldata keyword2,
		string calldata keyword3,
		string calldata keyword4) external;
	
	// 출시된 게임 ID들을 가져옵니다.
	function getPublishedGameIds() external view returns (uint[] memory);
	
	// 게임 ID들을 최신 순으로 가져옵니다.
	function getGameIdsNewest() external view returns (uint[] memory);
	
	// 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	function getGameIdsByRating(uint ratingCount) external view returns (uint[] memory);
	
	// 키워드에 해당하는 게임 ID들을 최신 순으로 가져옵니다.
	function getGameIdsByKeywordNewest(string calldata language, string calldata keyword) external view returns (uint[] memory);
	
	// 키워드에 해당하는 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	function getGameIdsByKeywordAndRating(string calldata language, string calldata keyword, uint ratingCount) external view returns (uint[] memory);
}