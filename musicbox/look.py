#!/usr/bin/python

#from graph_tool.all import *
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


threshold = 240

# threshold = 127
# secs_per_loop = 4

# def mintest():
#     g, pos = triangulation(random((400, 2)) * 10, type="delaunay")
#     weight = g.new_edge_property("double")
    
#     for e in g.edges():
#         weight[e] = norm(pos[e.target()].a - pos[e.source()].a)
#     tree = min_spanning_tree(g, weights=weight)
        
#     graph_draw(g, pos=pos, output="triang_orig.pdf")
#     g.set_edge_filter(tree)
#     graph_draw(g, pos=pos, output="triang_min_span_tree.pdf")

# def centralpoint(things):
#     if len(things) == 0:
#         return None

#     x = 0
#     y = 0
#     for thing in things:
#         x = x + thing['x']
#         y = y + thing['y']
#     x = x / len(things)
#     y = y / len(things)
    
#     return(x, y)

# def centralthing(things):
#     x, y = centralpoint(things)
    
#     if len(things) == 1:
#         return(things[0])

#     diffX = things[0]['x'] - x
#     diffY = things[0]['y'] - y
#     distance = math.sqrt(abs(diffX * diffX) + abs(diffY * diffY))
#     result = 0

#     for i in range(1, len(things)):
#         diffX = things[i]['x'] - x
#         diffY = things[i]['y'] - y
#         newDistance = math.sqrt(abs(diffX * diffX) + abs(diffY * diffY))
#         if newDistance < distance:
#             distance = newDistance
#             result = i
#     return(result)

# def travel(things, tree):
#     if len(things) == 0:
#         return(None)

#     for (i, thing) in enumerate(things):
#         thing['index'] = i
#         thing['next'] = []

#     i = centralthing(things)
#     central = things[i]
#     currentThings = [central]
#     things[i]['t'] = 0

#     biggestT = 0
#     while len(currentThings) > 0:
#         neighbours = []
#         for thing in currentThings:
#             thing['visited'] = True
#             i = thing['index']
#             for edge in tree:
#                 (ai, bi, distance) = edge
#                 neighbour = None
#                 if ai == i:
#                     neighbour = things[bi]
#                 elif bi == i:
#                     neighbour = things[ai]
#                 if neighbour != None:
#                     if not ('visited' in neighbour.keys()):
#                         thing['next'].append(neighbour)
#                         neighbour['prev'] = thing
#                         neighbour['t'] = thing['t'] + distance
#                         if neighbour['t'] > biggestT:
#                             biggestT = neighbour['t']
#                         neighbours.append(neighbour)
#         currentThings = neighbours

#     biggestT = biggestT * (float(len(things)) / float(len(things) - 1))

#     for thing in things:
#         timepc = 0
#         if biggestT > 0:
#             timepc = (thing['t'] / biggestT)
#         thing['timepc'] = timepc
#     return(central)

# def makeTree(things):
#     result = []
#     if len(things) == 0:
#         return
#     g = Graph(directed=False)
#     weight = g.new_edge_property("double")
#     if len(things) == 1:
#         vlist = [g.add_vertex(len(things))]
#     else:
#         vlist = list(g.add_vertex(len(things)))

#     for (i, a) in enumerate(vlist):
#         for (j, b) in enumerate(vlist):
#             e = g.add_edge(a, b)
#             diffX = things[i]['x'] - things[j]['x']
#             diffY = things[i]['y'] - things[j]['y']
#             distance = math.sqrt((diffX * diffX) + (diffY * diffY))
#             weight[e] = distance

#     tree = min_spanning_tree(g, weights = weight)
#     g.set_edge_filter(tree)
#     for e in g.edges():
#         ai = g.vertex_index[e.source()]
#         bi = g.vertex_index[e.target()]
#         result.append((ai, bi, weight[e]))
#     return result

# def sendMidi(midi_data):
#     path = "/dssi/nekobee/nekobee/chan00/midi"
#     liblo.send(tb303, path,
#                ('m', midi_data)
#                )
# def sendControl(control, value):
#     target = liblo.Address(nekoport)
#     path = "/dssi/nekobee/nekobee/chan00/control"
#     liblo.send(tb303, path, 
#                int(control),
#                float(value)
#                )


# def triggerOn(note, accent, duration):
#     if accent:
#         accent = 127
#     else:
#         accent = 60
#     midi_data = [0, 144, int(note), int(accent)]
#     sendMidi(midi_data)
#     schedule_noteOff(time.time() + duration, note)

# def triggerOff(note):
#     midi_data = [0, 128, note, 0]
#     sendMidi(midi_data)

# def schedule_noteOff(when, note):
#     global noteoffs
#     remove = []
#     for noteoff in noteoffs:
#         if noteoff['note'] == note:
#             remove.append(noteoff)
#     for noteoff in remove:
#         noteoffs.remove(noteoff)

#     noteoffs.append({'when': when, 'note': note})

# def do_noteoffs():
#     global noteoffs
#     remove = []
#     now = time.time()
#     for noteoff in noteoffs:
#         if noteoff['when'] <= now:
#             remove.append(noteoff)
#     for noteoff in remove:
#         triggerOff(noteoff['note'])
#         noteoffs.remove(noteoff)

# def play(thing):
#     resonance = thing['orientation']
#     envmod = (thing['roundness'] - 1.0) / 2.0
#     sendControl(TB_ENVMOD, envmod);
#     sendControl(TB_RESONANCE, resonance);

#     duration = 0.2
#     note = 80 - math.sqrt(thing['area'])
#     if (note < 30):
#         note = 30
#     triggerOn(note, 0, duration)

def runloop():
    global loops
    loops = 0
    cap = cv2.VideoCapture(1)
#    orig = cv2.blur(cv2.imread('image.jpg'), (3,3))
    
    while True:
        ret,grab = cap.read()
        things = []

        orig = grab
        im = cv2.GaussianBlur(orig, (0,0), 3)
        gray = cv2.cvtColor(im,cv2.COLOR_BGR2GRAY)
        ret,thresh = cv2.threshold(gray,threshold,255,0)
        contours, hierarchy = cv2.findContours(thresh,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)

        edges = cv2.Canny(gray,50,100,apertureSize = 3)
        #cv2.imshow('edges',edges)
        #cv2.waitKey(0)
        #cv2.destroyAllWindows()

        lines = cv2.HoughLines(edges,1,np.pi/180,50)
        
        for rho,theta in lines[0]:
            #print theta
            if theta > 2:
              next
            a = np.cos(theta)
            b = np.sin(theta)
            x0 = a*rho
            y0 = b*rho
            x1 = int(x0 + 1000*(-b))
            y1 = int(y0 + 1000*(a))
            x2 = int(x0 - 1000*(-b))
            y2 = int(y0 - 1000*(a))
            cv2.line(orig,(x1,y1),(x2,y2),(0,0,255),2)

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
            #thing['rect'] = rect = cv2.boundingRect(c)
            #thing['hull'] = hull = cv2.convexHull(c)
            #thing['hull_area'] = abs(cv2.contourArea(hull))
            
            #thing['perimeter'] = perimeter = cv2.arcLength(c, True)
            #thing['roundness'] = (perimeter * 0.282) / math.sqrt(area)
            #(centre, axes, orientation) = cv2.fitEllipse(c)
            #thing['centre'] = centre
            #print ("centre: " + str(centre))
            #thing['orientation'] = orientation / 180
            # TODO - check these are width and height
            #thing['aspect'] = float(rect[1]) / float(rect[3])
            thing['contour'] = [c]
            # TODO - brightness
            #cv2.drawContours(orig,[c],-1, ((i/float(len(contours)))*256.0, 0,255), 2)
            things.append(thing)

        loops = loops + 1
      
        frame = orig.copy()
        for thing in things:
            cv2.drawContours(frame,thing['contour'],-1, (255,0,0), -1)
            x = thing['x']
            y = thing['y']
            cv2.line(frame, (int(x-4),int(y)), (int(x+4),int(y)), (0,255,0), 1)
            cv2.line(frame, (int(x),int(y-4)), (int(x),int(y+4)), (0,255,0), 1)
        im2 = Image.fromarray(np.array(orig))
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
height = 800
width = 800
screen = pygame.display.set_mode((width,height))
pygame.display.set_caption("musicbox")


runloop()
pygame.quit()
