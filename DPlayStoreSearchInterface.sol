pragma solidity ^0.5.9;

interface DPlayStoreSearchInterface {
	
	// 태그 정보
	// Tags info
	struct GameTags {
		string tag1;
		string tag2;
		string tag3;
		string tag4;
	}
	
	// 언어별로 게임의 태그를 입력합니다.
	// Sets the tags of a game for each language.
	function setGameDetails(
		uint gameId,
		string calldata language,
		string calldata tag1,
		string calldata tag2,
		string calldata tag3,
		string calldata tag4) external;
	
	// 출시된 게임 ID들을 가져옵니다.
	// Gets the IDs of the released games.
	function getPublishedGameIds() external view returns (uint[] memory);
	
	// 게임 ID들을 최신 순으로 가져옵니다.
	// Gets the game IDs and sort them in the chronological order.
	function getGameIdsNewest() external view returns (uint[] memory);
	
	// 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	// Gets game IDs, exclude the games with the low number of ratings and sort the unexcluded games in the descending rating order.
	function getGameIdsByRating(uint ratingCount) external view returns (uint[] memory);
	
	// 태그에 해당하는 게임 ID들을 최신 순으로 가져옵니다.
	// Gets Game IDs based on the tags and sort them in the chronological order.
	function getGameIdsByTagNewest(string calldata language, string calldata tag) external view returns (uint[] memory);
	
	// 태그에 해당하는 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	// Get game IDs based on the tags, exclude the games with the low number of ratings and sort the unexcluded games in the descending rating order.
	function getGameIdsByTagAndRating(string calldata language, string calldata tag, uint ratingCount) external view returns (uint[] memory);
}
