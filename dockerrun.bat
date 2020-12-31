docker run ^
				--isolation=process ^
				--mount type=bind,source=D:\phoenix-firestorm,target=C:\phoenix-firestorm ^
				--mount type=bind,source=D:\phonixbuilder\config,target=C:\config ^
				-it ^
				phonixbuilder ^
				cmd