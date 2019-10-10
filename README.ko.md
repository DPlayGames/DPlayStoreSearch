# DPlay Store Search

## 계약 주소
- Mainnet: 0xaD7Ba3338A48F144f5ec311f40Ac2555C0458686
- Kovan: 0xbF92bE17b53fa3d727f1DB47a2dd7A56AF42F5dF
- Ropsten: 0x4BfF6b76c414f13399738A575e8Cd6346D6d41E6
- Rinkeby: 0xdb62D4192aA5239F36545C287a8d2DA21b9c4878

## 테스트 여부
- ![테스트 여부](https://img.shields.io/badge/테스트%20여부-yes-brightgreen.svg) `function setGameTags(uint gameId, string calldata language, string calldata tag1, string calldata tag2, string calldata tag3, string calldata tag4) external`
- ![테스트 여부](https://img.shields.io/badge/테스트%20여부-yes-brightgreen.svg) `function getGameTags(uint gameId, string calldata language) external view returns (string memory tag1, string memory tag2, string memory tag3, string memory tag4)`
- ![테스트 여부](https://img.shields.io/badge/테스트%20여부-no-red.svg) `function getReleasedGameIds() external view returns (uint[] memory)`
- ![테스트 여부](https://img.shields.io/badge/테스트%20여부-yes-brightgreen.svg) `function getGameIdsNewest() external view returns (uint[] memory)`
- ![테스트 여부](https://img.shields.io/badge/테스트%20여부-no-red.svg) `function getGameIdsByRating(uint ratingCount) external view returns (uint[] memory)`
- ![테스트 여부](https://img.shields.io/badge/테스트%20여부-no-red.svg) `function getGameIdsByTagNewest(string calldata language, string calldata tag) external view returns (uint[] memory)`
- ![테스트 여부](https://img.shields.io/badge/테스트%20여부-no-red.svg) `function getGameIdsByTagAndRating(string calldata language, string calldata tag, uint ratingCount) external view returns (uint[] memory)`