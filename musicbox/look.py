#!/usr/bin/python

from numpy.linalg import norm
from numpy.random import random
import pygame
from pygame.locals import *
import math
import cv2
import Image
import numpy as np
import liblo
import time
import subprocess
import sys
from OSC import OSCClient, OSCMessage


threshold = 240

port = 9000
osc = OSCClient()
osc.connect( ("localhost", port) )

def runloop():
    global loops
    loops = 0
    cap = cv2.VideoCapture(1)
    #    orig = cv2.blur(cv2.imread('image.jpg'), (3,3))
    ret,grab = cap.read()
    cv2.imwrite('save.png',grab)
    #grab = grab[170:270,140:440]
    #roi = grab[170:270,140:440]
    # top left: 100,145
    # bottom right: 500,275
    grab = grab[145:275,100:500]
    roi = grab[145:275,100:500]
    cv2.imwrite('roi.png',grab)

    low = 1000
    high = 0

    highest = 300.5
    lowest = 40.6

    current_notes = []
    
    note_names = ['c0','d0','e0','f0','g0','a1','b1',
                  'c1','d1','e1','f1','g1','a2','b2',
                  'c2'
    ]
    note_names.reverse()
    
    midi = [0,2,4,5,7,9,11,12,14,16,17,19,21,23,24]
    midi.reverse()
    
    while True:
        ret,grab = cap.read()
        #grab = grab[170:270,140:465]
        grab = grab[145:275,100:500]
        cv2.imwrite('update.png',grab)
        things = []

        orig = grab
        im = cv2.GaussianBlur(orig, (0,0), 3)
        gray = cv2.cvtColor(im,cv2.COLOR_BGR2GRAY)
        ret,thresh = cv2.threshold(gray,threshold,255,0)
        contours, hierarchy = cv2.findContours(thresh,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)

        edges = cv2.Canny(gray,50,100,apertureSize = 3)

        for (i, c) in enumerate(contours):
            area = cv2.contourArea(c)
            if area < 100:
                continue

            #print "area %i: %f" % (i, area)
            thing = {}
            thing['area'] = area

            # centroid
            m = cv2.moments(c)
            thing['x'] = m['m10'] / m['m00']
            thing['y'] = m['m01'] / m['m00']
            
            thing['perimeter'] = perimeter = cv2.arcLength(c, True)
            thing['roundness'] = roundness = (perimeter * 0.282) / math.sqrt(area)
            thing['contour'] = [c]
            # TODO - brightness
            #cv2.drawContours(orig,[c],-1, ((i/float(len(contours)))*256.0, 0,255), 2)
            note = int(round((thing['x'] - lowest) / (highest - lowest) * 14))
            if note > 14:
                note = 14
            if note < 0:
                note = 0
            thing['note'] = note

            #print "area: " + str(area) + " roundness: " + str(roundness)
            if roundness < 1.1 and area < 800: #area > 100 and area < 600 and roundness < 1.1:
                if thing['x'] < low:
                    low = thing['x']
                    print "highest " + str(high) + " lowest: " + str(low)
                if thing['x'] > high:
                    high = thing['x']
                    print "highest " + str(high) + " lowest: " + str(low)
                things.append(thing)

        loops = loops + 1

        things = sorted(things, key=lambda thing: thing['y']) 

        frame = orig.copy()
        for thing in things:
            note = thing['note']
            #print("note: " + str(note) + " (" + note_names[note] + ")")
            cv2.drawContours(frame,thing['contour'],-1, (255,0,0), -1)
            x = thing['x']
            y = thing['y']
            cv2.line(frame, (int(x-4),int(y)), (int(x+4),int(y)), (0,255,0), 1)
            cv2.line(frame, (int(x),int(y-4)), (int(x),int(y+4)), (0,255,0), 1)
            cv2.putText(frame,note_names[note],(int(x+6),int(y-6)), cv2.FONT_HERSHEY_SIMPLEX, 0.5,(0,0,255),2)

        new_notes = list(map (lambda thing: thing['note'],things))

        if new_notes != current_notes:
            current_notes = new_notes
            message = OSCMessage("/notes")
            message.append(map(lambda n: midi[n],current_notes))
            osc.send( message )

        im2 = Image.fromarray(np.array(frame))
        pg_img = pygame.image.frombuffer(im2.tobytes(), im2.size, im2.mode)
	screen.blit(pg_img, (0,0))
        pygame.display.flip()

        while 1:
            ev = pygame.event.poll()
            if ev.type == pygame.QUIT:
                sys.exit("bye")
            elif ev.type == pygame.NOEVENT:
                break

        time.sleep(0.1)

pygame.init()
height = 100
width = 325
screen = pygame.display.set_mode((width,height))
pygame.display.set_caption("musicbox")


runloop()
pygame.quit()
