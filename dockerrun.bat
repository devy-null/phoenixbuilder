docker run ^
				--isolation=process ^
				--mount type=bind,source=D:\phoenix-firestorm,target=C:\phoenix-firestorm ^
				--mount type=bind,source=D:\phoenixbuilder\config,target=C:\config ^
				-it ^
				phoenixbuilder ^
				cmd