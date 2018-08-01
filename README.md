# Instagallery_proj
Simple gallery for user instagram profile. 

Developed using:
Xcode 9.4 / Swift 4.1

Description:
This application parses single photos and photos from collection for logged in   user. 
To display parsed photos it uses collection view with custom layouts. 
Gallery has three diplaying modes: 
- display as thumbnails;
- display as custom flow layout;
- display choosed image in fullsize;
Application have some examples for using gradient, presenting custom animation and unit tests.

Important to know: 
If you want to use this poject you should register your own client instagram app on 
https://www.instagram.com/developer/register/ 
After registration you should get redirectlink, client id and client secret and place them to the InstagramApiProvider class,
you will find some constants for them.
(see more information about using instagram client app on: https://www.instagram.com/developer)


This project uses pods:
- Moya, '~> 11.0';
- Moya-ObjectMapper;
- AlamofireImage, '~> 3.3';
- R.swift;
- PKHUD, '~> 5.0';
- Keychain;
- BubbleTransition, '~> 2.0.0';
