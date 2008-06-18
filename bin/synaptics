#!/bin/sh

SYNDPIDFILE=$HOME/.syndaemon.pid
SYNDOPTS="-k -t -d 0.5"

if [ -f $SYNDPIDFILE ]; then
	kill $(cat $SYNDPIDFILE)
fi

case "$1" in
	left)
		synclient \
			Xrandr=2 \
			TopEdge=5072 LeftEdge=1712 BottomEdge=1872 RightEdge=4144 \
			FingerLow=25 FingerHigh=30 FingerPress=256 \
			MaxTapTime=180 MaxTapMove=220 \
			MaxDoubleTapTime=180 \
			SingleTapTimeout=180 \
			ClickTime=100 \
			FastTaps=0 \
			EmulateMidButtonTime=75 \
			EmulateTwoFingerMinZ=257 \
			VertScrollDelta=60 HorizScrollDelta=80 \
			VertEdgeScroll=0 HorizEdgeScroll=0 \
			VertTwoFingerScroll=1 HorizTwoFingerScroll=0 \
			CornerCoasting=1 \
			MinSpeed=0.0822368 MaxSpeed=0.197368 AccelFactor=0.00216818 \
			TrackstickSpeed=40 \
			EdgeMotionMinZ=30 EdgeMotionMaxZ=160 \
			EdgeMotionMinSpeed=1 EdgeMotionMaxSpeed=304 \
			EdgeMotionUseAlways=0 \
			UpDownScrolling=1 LeftRightScrolling=1 \
			UpDownScrollRepeat=1 LeftRightScrollRepeat=1 \
			ScrollButtonRepeat=100 \
			TouchpadOff=0 GuestMouseOff=0 \
			LockedDrags=1 LockedDragTimeout=500 \
			RTCornerButton=2 RBCornerButton=3 LTCornerButton=0 LBCornerButton=0 \
			TapButton1=1 TapButton2=2 TapButton3=3 \
			CircularScrolling=0 CircScrollDelta=0.1 CircScrollTrigger=7 \
			CircularPad=0 \
			PalmDetect=1 PalmMinWidth=10 PalmMinZ=200 \
			CoastingSpeed=0 \
			PressureMotionMinZ=30 PressureMotionMaxZ=160 \
			PressureMotionMinFactor=1 PressureMotionMaxFactor=8 \
			GrabEventDevice=1
		;;
	right)
		synclient \
			Xrandr=1 \
			TopEdge=5072 LeftEdge=1712 BottomEdge=1872 RightEdge=4144 \
			FingerLow=25 FingerHigh=30 FingerPress=256 \
			MaxTapTime=180 MaxTapMove=220 \
			MaxDoubleTapTime=180 \
			SingleTapTimeout=180 \
			ClickTime=100 \
			FastTaps=0 \
			EmulateMidButtonTime=75 \
			EmulateTwoFingerMinZ=257 \
			VertScrollDelta=60 HorizScrollDelta=80 \
			VertEdgeScroll=0 HorizEdgeScroll=0 \
			VertTwoFingerScroll=1 HorizTwoFingerScroll=0 \
			CornerCoasting=1 \
			MinSpeed=0.0822368 MaxSpeed=0.197368 AccelFactor=0.00216818 \
			TrackstickSpeed=40 \
			EdgeMotionMinZ=30 EdgeMotionMaxZ=160 \
			EdgeMotionMinSpeed=1 EdgeMotionMaxSpeed=304 \
			EdgeMotionUseAlways=0 \
			UpDownScrolling=1 LeftRightScrolling=1 \
			UpDownScrollRepeat=1 LeftRightScrollRepeat=1 \
			ScrollButtonRepeat=100 \
			TouchpadOff=0 GuestMouseOff=0 \
			LockedDrags=1 LockedDragTimeout=500 \
			RTCornerButton=2 RBCornerButton=3 LTCornerButton=0 LBCornerButton=0 \
			TapButton1=1 TapButton2=2 TapButton3=3 \
			CircularScrolling=0 CircScrollDelta=0.1 CircScrollTrigger=7 \
			CircularPad=0 \
			PalmDetect=1 PalmMinWidth=10 PalmMinZ=200 \
			CoastingSpeed=0 \
			PressureMotionMinZ=30 PressureMotionMaxZ=160 \
			PressureMotionMinFactor=1 PressureMotionMaxFactor=8 \
			GrabEventDevice=1
		;;
	inverted)
		synclient \
			Xrandr=3 \
			LeftEdge=1872 RightEdge=5072 TopEdge=1712 BottomEdge=4144 \
			FingerLow=25 FingerHigh=30 FingerPress=256 \
			MaxTapTime=180 MaxTapMove=220 \
			MaxDoubleTapTime=180 \
			SingleTapTimeout=180 \
			ClickTime=100 \
			FastTaps=0 \
			EmulateMidButtonTime=75 \
			EmulateTwoFingerMinZ=257 \
			VertScrollDelta=60 HorizScrollDelta=80 \
			VertEdgeScroll=0 HorizEdgeScroll=0 \
			VertTwoFingerScroll=0 HorizTwoFingerScroll=0 \
			CornerCoasting=1 \
			MinSpeed=0.0822368 MaxSpeed=0.197368 AccelFactor=0.00216818 \
			TrackstickSpeed=40 \
			EdgeMotionMinZ=30 EdgeMotionMaxZ=160 \
			EdgeMotionMinSpeed=1 EdgeMotionMaxSpeed=304 \
			EdgeMotionUseAlways=0 \
			UpDownScrolling=1 LeftRightScrolling=1 \
			UpDownScrollRepeat=1 LeftRightScrollRepeat=1 \
			ScrollButtonRepeat=100 \
			TouchpadOff=0 GuestMouseOff=0 \
			LockedDrags=1 LockedDragTimeout=500 \
			RTCornerButton=2 RBCornerButton=3 LTCornerButton=0 LBCornerButton=0 \
			TapButton1=1 TapButton2=2 TapButton3=3 \
			CircularScrolling=1 CircScrollDelta=0.1 CircScrollTrigger=7 \
			CircularPad=0 \
			PalmDetect=1 PalmMinWidth=10 PalmMinZ=200 \
			CoastingSpeed=0 \
			PressureMotionMinZ=30 PressureMotionMaxZ=160 \
			PressureMotionMinFactor=1 PressureMotionMaxFactor=8 \
			GrabEventDevice=1
		;;
	*)
		synclient \
			Xrandr=0 \
			LeftEdge=1872 RightEdge=5072 TopEdge=1712 BottomEdge=4144 \
			FingerLow=25 FingerHigh=30 FingerPress=256 \
			MaxTapTime=180 MaxTapMove=220 \
			MaxDoubleTapTime=180 \
			SingleTapTimeout=180 \
			ClickTime=100 \
			FastTaps=0 \
			EmulateMidButtonTime=75 \
			EmulateTwoFingerMinZ=257 \
			VertScrollDelta=60 HorizScrollDelta=80 \
			VertEdgeScroll=0 HorizEdgeScroll=0 \
			VertTwoFingerScroll=0 HorizTwoFingerScroll=0 \
			CornerCoasting=1 \
			MinSpeed=0.0822368 MaxSpeed=0.197368 AccelFactor=0.00216818 \
			TrackstickSpeed=40 \
			EdgeMotionMinZ=30 EdgeMotionMaxZ=160 \
			EdgeMotionMinSpeed=1 EdgeMotionMaxSpeed=304 \
			EdgeMotionUseAlways=0 \
			UpDownScrolling=1 LeftRightScrolling=1 \
			UpDownScrollRepeat=1 LeftRightScrollRepeat=1 \
			ScrollButtonRepeat=100 \
			TouchpadOff=0 GuestMouseOff=0 \
			LockedDrags=1 LockedDragTimeout=500 \
			RTCornerButton=2 RBCornerButton=3 LTCornerButton=0 LBCornerButton=0 \
			TapButton1=1 TapButton2=2 TapButton3=3 \
			CircularScrolling=1 CircScrollDelta=0.1 CircScrollTrigger=7 \
			CircularPad=0 \
			PalmDetect=1 PalmMinWidth=10 PalmMinZ=200 \
			CoastingSpeed=0 \
			PressureMotionMinZ=30 PressureMotionMaxZ=160 \
			PressureMotionMinFactor=1 PressureMotionMaxFactor=8 \
			GrabEventDevice=1
		;;
esac

syndaemon -d -p $SYNDPIDFILE $SYNDOPTS
