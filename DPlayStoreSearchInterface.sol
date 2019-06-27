pragma solidity ^0.5.9;

interface DPlayStoreSearchInterface {
	
	// Tags info
	// 태그 정보
	struct GameTags {
		string tag1;
		string tag2;
		string tag3;
		string tag4;
	}
	
	// Sets the tags of a game for each language.
	// 언어별로 게임의 태그들을 입력합니다.
	function setGameTags(
		uint gameId,
		string calldata language,
		string calldata tag1,
		string calldata tag2,
		string calldata tag3,
		string calldata tag4) external;
	
	// 게임의 태그들을 가져옵니다.
	function getGameTags(uint gameId, string calldata language) external view returns (
		string memory tag1,
		string memory tag2,
		string memory tag3,
		string memory tag4
	);
	
	// Gets the IDs of the released games.
	// 출시된 게임 ID들을 가져옵니다.
	function getReleasedGameIds() external view returns (uint[] memory);
	
	// Gets the game IDs and sort them in the chronological order.
	// 게임 ID들을 최신 순으로 가져옵니다.
	function getGameIdsNewest() external view returns (uint[] memory);
		
	// Gets game IDs, exclude the games with the low number of ratings and sort the unexcluded games in the descending rating order.
	// 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	function getGameIdsByRating(uint ratingCount) external view returns (uint[] memory);
	
	// Gets Game IDs based on the tags and sort them in the chronological order.
	// 태그에 해당하는 게임 ID들을 최신 순으로 가져옵니다.
	function getGameIdsByTagNewest(string calldata language, string calldata tag) external view returns (uint[] memory);
	
	// Get game IDs based on the tags, exclude the games with the low number of ratings and sort the unexcluded games in the descending rating order.
	// 태그에 해당하는 게임 ID들을 높은 점수 순으로 가져오되, 평가 수로 필터링합니다.
	function getGameIdsByTagAndRating(string calldata language, string calldata tag, uint ratingCount) external view returns (uint[] memory);
}
